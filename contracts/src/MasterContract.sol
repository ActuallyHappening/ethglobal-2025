// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

contract MasterContract {
    mapping(address => bool) public whitelist;
    uint256 public maxTransfer;
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal {
        require(msg.sender == owner, "Only owner can call this function");
    }

    function addToWhitelist(address _wallet) external onlyOwner {
        whitelist[_wallet] = true;
    }

    function removeFromWhitelist(address _wallet) external onlyOwner {
        whitelist[_wallet] = false;
    }

    function whitelistContains(address _wallet) public view returns (bool) {
        return whitelist[_wallet];
    }

    function setMaxTransfer(uint256 _maxTransfer) external onlyOwner {
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
