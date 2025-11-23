// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {IMasterControl} from "./IMasterControl.sol";

struct Call {
    address to;
    uint256 value;
    bytes data;
}

contract EIP7702 {
    address public verifyingContract;
    address public owner;

    event Executed(
        address indexed caller,
        address indexed recipient,
        uint256 amount,
        bytes data
    );

    error InvalidMasterControl();
    error CallInvalid();
    error CallReverted();
    error MustHaveOwner();

    constructor(address _verifyingContract, address _owner) {
        if (_verifyingContract == address(0)) revert InvalidMasterControl();
        verifyingContract = _verifyingContract;

        if (_verifyingContract == address(0)) revert MustHaveOwner();
        owner = _owner;
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        if (owner != msg.sender) revert InvalidMasterControl();
    }

    function updateVerifyingContract(
        address _verifyingContract
    ) external onlyOwner {
        verifyingContract = _verifyingContract;
    }

    /// @notice Allows receiving ETHer as normal
    receive() external payable {}

    function verify(Call calldata _call) public view returns (bool) {
        bool allowed = IMasterControl(verifyingContract).verify(
            _call.to,
            _call.value,
            _call.data
        );
        return allowed;
    }

    function execute(Call[] calldata calls) external payable {
        require(
            msg.sender == address(this),
            "Invalid authority: Not running from my EOA"
        );
        for (uint256 i = 0; i < calls.length; i++) {
            Call calldata call = calls[i];

            if (!verify(call)) {
                revert CallInvalid();
            }

            (bool success, ) = call.to.call{value: call.value}(call.data);

            if (!success) revert CallReverted();

            emit Executed(msg.sender, call.to, call.value, call.data);
        }
    }
}
