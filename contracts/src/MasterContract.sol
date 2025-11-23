// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

contract MasterContract {
    mapping(address => bool) public whitelist;
    uint256 public maxTransfer;

    function addToWhitelist(address _wallet) external {
        whitelist[_wallet] = true;
    }

    function removeFromWhitelist(address _wallet) external {
        whitelist[_wallet] = false;
    }

    function whitelistContains(address _wallet) public view returns (bool) {
        return whitelist[_wallet];
    }

    function setMaxTransfer(uint256 _maxTransfer) external {
        maxTransfer = _maxTransfer;
    }

    function verify(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external view returns (bool) {
        if (whitelistContains(recipient) && amount <= maxTransfer) {
            return true;
        }
        return false;
    }
}
