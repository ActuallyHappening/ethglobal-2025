// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title IMasterControl
/// @notice Interface for the MasterControl verifier contract
interface IMasterControl {
    /// @notice Verify if a transaction is allowed based on the transaction details
    /// @param recipient The recipient address of the transaction
    /// @param amount The amount being transferred
    /// @return bool True if the transaction is allowed, false otherwise
    function verify(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external view returns (bool);
}
