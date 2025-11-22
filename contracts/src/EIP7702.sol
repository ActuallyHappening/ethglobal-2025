// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IMasterControl.sol";

/// @title EIP7702
contract EIP7702 {
    /// @notice Reference to the MasterContract verifier
    address public verifyingContract;

    /// @notice The master account that can update the validation
    /// [verifyingContract] of this EOA
    address public owner;

    /// @notice Event emitted when a transaction is validated
    event Executed(
        address indexed caller,
        address indexed recipient,
        uint256 amount,
        bytes data
    );

    /// @notice Error when MasterControl address is invalid
    error InvalidMasterControl();

    /// @notice Error when transaction is not allowed
    error TransactionInvalid();

    error MustHaveOwner();

    /// @notice Constructor sets the immutable MasterControl address
    constructor(address _verifyingContract, address _owner) {
        if (_verifyingContract == address(0)) revert InvalidMasterControl();
        verifyingContract = _verifyingContract;

        if (_verifyingContract == address(0)) revert MustHaveOwner();
        owner = _owner;
    }

    modifier onlyOwner() {
        if (owner != msg.sender) revert InvalidMasterControl();
        _;
    }

    function updateVerifyingContract(
        address _verifyingContract
    ) external onlyOwner {
        verifyingContract = _verifyingContract;
    }

    function verify(Call calldata _call) public view returns (bool) {
        bool allowed = IMasterControl(verifyingContract).verify(
            _call.to,
            _call.value,
            _call.data
        );
        return allowed;
    }

    struct Call {
        address to;
        uint256 value;
        bytes data;
    }

    function execute(Call[] calldata calls) external payable {
        require(msg.sender == address(this), "Invalid authority");
        for (uint256 i = 0; i < calls.length; i++) {
            Call memory call = calls[i];

            (bool success, ) = call.to.call{value: call.value}(call.data);

            // require(success, "call reverted");
            if (!success) revert TransactionInvalid();

            emit Executed(msg.sender, call.to, call.value, call.data);
        }
    }
}
