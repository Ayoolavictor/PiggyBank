// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./PiggyBank.sol";

contract PiggyBankFactory {
    mapping(address => address[]) public userPiggyBanks;
    event PiggyBankDeployed(address indexed owner, address piggyBankAddress);

    function deployPiggyBank(
        address _usdc,
        address _usdt,
        address _dai,
        bytes32 _salt
    ) external returns (address) {
    

        PiggyBankContract piggyBank = new PiggyBankContract{salt: _salt}(
            _usdc,
            _usdt,
            _dai
        );

        // Store the deployed contract address
        userPiggyBanks[msg.sender].push(address(piggyBank));

        emit PiggyBankDeployed(msg.sender, address(piggyBank));
        return address(piggyBank);
    }

    function getUserPiggyBanks(
        address _user
    ) external view returns (address[] memory) {
        return userPiggyBanks[_user];
    }

    function getAddress(
        bytes32 _salt,
        address _usdc,
        address _usdt,
        address _dai
    ) public view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(PiggyBankContract).creationCode,
            abi.encode(_usdc, _usdt, _dai)
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode)
            )
        );
        return address(uint160(uint256(hash)));
    }
}
