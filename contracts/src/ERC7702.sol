// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IMasterControl.sol";

/// @title ERC7702
/// @notice EIP-7702 delegation contract that enforces MasterControl policies
contract ERC7702 {
    /// @notice Immutable reference to the MasterControl verifier
    address public immutable masterControl;

    /// @notice Event emitted when a transaction is executed
    event Executed(address indexed caller, address indexed recipient, uint256 amount);

    /// @notice Error when MasterControl address is invalid
    error InvalidMasterControl();

    /// @notice Error when transaction is not allowed
    error TransactionNotAllowed();

    /// @notice Constructor sets the immutable MasterControl address
    /// @param _masterControl The address of the MasterControl verifier
    constructor(address _masterControl) {
        if (_masterControl == address(0)) revert InvalidMasterControl();
        masterControl = _masterControl;
    }

    /// @notice Execute a transaction after verification by MasterControl
    /// @param recipient The recipient address
    /// @param amount The amount to transfer
    /// @return True if execution was successful
    function execute(address recipient, uint256 amount) external returns (bool) {
        // Verify with MasterControl
        bool allowed = IMasterControl(masterControl).verify(recipient, amount);

        if (!allowed) revert TransactionNotAllowed();

        // Emit event on successful execution
        emit Executed(msg.sender, recipient, amount);

        return true;
    }
}
