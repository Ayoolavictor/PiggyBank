// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./interface/IpiggyBank.sol";

import "@openzeppelin/contracts/interfaces/IERC20.sol";

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

error ZeroAmount(uint256 _amount);
error ZeroDuration(uint256 _duration);
error NotASaver(address _saver);
error ZeroAddress(address _saver);
error TokenNotAllowed(address _token);
error ActivePiggyBankExists(address _saver);

contract PiggyBankContract is IpiggyBank, ReentrancyGuard {
    using SafeERC20 for IERC20;
    address public immutable usdcAddress;
    address public immutable daiAddress;
    address public immutable usdtAddress;
    uint256 public constant PENALTY_PERCENT = 15;

    event PiggyBankCreated(
        address _saver,
        address _tokenAddress,
        uint256 _initialAmount,
        uint256 _startTime,
        uint256 _duration
    );
    event DepositReceived(
        address _saver,
        address _tokenAddress,
        uint256 amount,
        uint256 time
    );
    event FundsWithdrawn(
        address _saver,
        address _tokenAddress,
        uint256 amount,
        uint256 time,
        bool isPenalty
    );
    mapping(address => PiggyBank) userBanks;
    modifier tokenAllowed(address _tokenAddress) {
        if (
            _tokenAddress != usdcAddress &&
            _tokenAddress != daiAddress &&
            _tokenAddress != usdtAddress
        ) {
            revert TokenNotAllowed(_tokenAddress);
        }
        _;
    }
    modifier onlySaver() {
        if (userBanks[msg.sender].saver != msg.sender)
            revert NotASaver(msg.sender);
        _;
    }

    constructor(
        address _usdcAddress,
        address _usdtAddress,
        address _daiAddress
    ) {
        usdcAddress = _usdcAddress;
        daiAddress = _daiAddress;
        usdtAddress = _usdtAddress;
    }

    function openPiggyBank(
        address _tokenAddress,
        uint256 _initialAmount,
        string memory _reason,
        uint256 _duration
    ) external tokenAllowed(_tokenAddress) nonReentrant {
        if (_initialAmount <= 0) {
            revert ZeroAmount(_initialAmount);
        }
        if (_duration <= 0) {
            revert ZeroDuration(_duration);
        }
        if (userBanks[msg.sender].saver != address(0))
            revert ActivePiggyBankExists(msg.sender);

        IERC20(_tokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _initialAmount
        );

        PiggyBank memory bank = PiggyBank({
            saver: msg.sender,
            tokenAddress: _tokenAddress,
            reason: _reason,
            startDate: block.timestamp,
            duration: _duration,
            amountSaved: _initialAmount
        });
        userBanks[msg.sender] = bank;
        emit PiggyBankCreated(
            msg.sender,
            _tokenAddress,
            _initialAmount,
            block.timestamp,
            _duration
        );
    }

    function deposit(uint256 _amount) external onlySaver nonReentrant {
        if (_amount == 0) revert ZeroAmount(_amount);
        PiggyBank storage bank = userBanks[msg.sender];

        IERC20(bank.tokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
        bank.amountSaved += _amount;

        emit DepositReceived(
            msg.sender,
            bank.tokenAddress,
            _amount,
            block.timestamp
        );
    }

    function withdraw() external onlySaver nonReentrant {
        PiggyBank storage bank = userBanks[msg.sender];
        uint256 withdrawAmount = bank.amountSaved;
        address token = bank.tokenAddress;

        bool isPenalty = block.timestamp < bank.startDate + bank.duration;
        if (isPenalty) {
            uint256 penaltyFee = (withdrawAmount * PENALTY_PERCENT) / 100;
            withdrawAmount -= penaltyFee;
        }
        delete userBanks[msg.sender];
        IERC20(token).safeTransfer(msg.sender, withdrawAmount);

        emit FundsWithdrawn(
            msg.sender,
            token,
            withdrawAmount,
            block.timestamp,
            isPenalty
        );
    }

    function getBalanceSaver() external view returns (uint256) {
        return userBanks[msg.sender].amountSaved;
    }
}
