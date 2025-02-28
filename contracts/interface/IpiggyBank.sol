// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IpiggyBank {
    struct PiggyBank {
        address saver;
        address tokenAddress;
        string reason;
        uint256 startDate;
        uint256 duration;
        uint256 amountSaved;
    }

    function openPiggyBank(
        address _tokenAddress,
        uint256 _savedAmount,
        string memory _reason,
        uint256 _duration
    ) external;

    function deposit(uint256 _amount) external;

    function withdraw() external;

    function getBalanceSaver() external view returns (uint256);
}
