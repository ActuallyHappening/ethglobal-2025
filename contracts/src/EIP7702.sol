// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IMasterControl.sol";

/// @title EIP7702
/// @notice EIP-7702 delegation contract that enforces MasterControl policies
contract EIP7702 {
    /// @notice Immutable reference to the MasterControl verifier
    address public immutable masterControl;

    /// @notice Event emitted when a transaction is executed
    event Executed(
        address indexed caller,
        address indexed recipient,
        uint256 amount,
        bytes data
    );

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
    /// @param _recipient The recipient address
    /// @param _amount The amount to transfer
    /// @return True if execution was successful
    function execute(
        address _recipient,
        uint256 _amount,
        bytes memory _data
    ) external returns (bool) {
        // Verify with MasterControl
        bool allowed = IMasterControl(masterControl).verify(
            _recipient,
            _amount
        );

        if (!allowed) revert TransactionNotAllowed();

        /*  (bool success, ) = _recipient.delegatecall(abi.encodeWithSignature("", _data));
         require(success, "Delegate call failed"); */
        // Emit event on successful execution
        emit Executed(msg.sender, _recipient, _amount, _data);

        return true;
    }
}
