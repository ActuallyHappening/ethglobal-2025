// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/7702.sol";

/// @title TestOrgDelegateHandler
/// @notice Tests for the OrgDelegateHandler contract, which acts as the delegation target for EIP-7702.
contract TestOrgDelegateHandler is Test {
    OrgDelegateHandler public handler;
    address public mockMasterControlProxy;
    address public mockMasterControlProxyReject;

    event TransactionExecuted(bytes32 indexed txHash, bool allowed);
    event TransactionBlocked(bytes32 indexed txHash, string reason);

    function setUp() public {
        // Deploy mock master control proxies
        mockMasterControlProxy = address(new MockMasterControlProxyAccept());
        mockMasterControlProxyReject = address(new MockMasterControlProxyReject());

        // Deploy OrgDelegateHandler with accepting mock
        handler = new OrgDelegateHandler(mockMasterControlProxy);
    }

    /// @notice Test that the handler is initialized with the correct proxy address.
    function test_handlerInitialization() public {
        assertEq(handler.masterControlProxy(), mockMasterControlProxy, "Master control proxy address mismatch");
    }

    /// @notice Test that verifyPayload returns true when proxy allows the transaction.
    function test_verifyPayload_Allowed() public {
        bytes memory payload = abi.encode(uint256(42));
        bool allowed = handler.verifyPayload(payload);
        assertTrue(allowed, "Payload should be allowed by proxy");
    }

    /// @notice Test that verifyPayload returns false when proxy denies the transaction.
    function test_verifyPayload_Denied() public {
        // Redeploy handler with rejecting proxy
        OrgDelegateHandler rejectingHandler = new OrgDelegateHandler(mockMasterControlProxyReject);
        bytes memory payload = abi.encode(uint256(42));
        bool allowed = rejectingHandler.verifyPayload(payload);
        assertFalse(allowed, "Payload should be denied by proxy");
    }

    /// @notice Test that verifyPayload emits TransactionExecuted event on success.
    function test_verifyPayload_EmitsEvent_OnSuccess() public {
        bytes memory payload = abi.encode(uint256(42));
        bytes32 expectedHash = keccak256(payload);

        vm.expectEmit(true, false, false, false);
        emit TransactionExecuted(expectedHash, true);

        handler.verifyPayload(payload);
    }

    /// @notice Test fallback function intercepts calls (simulated via verifyPayload).
    function test_fallback_Behavior() public {
        bytes memory calldata_payload = abi.encode(uint256(100), address(this));
        bool result = handler.verifyPayload(calldata_payload);
        assertTrue(result, "Fallback handler should allow verified transactions");
    }

    /// @notice Test that handler can receive ETH via receive function.
    function test_receiveEth() public {
        uint256 amount = 1 ether;
        (bool success,) = address(handler).call{value: amount}("");
        assertTrue(success, "Handler should receive ETH");
    }

    /// @notice Test handler with rejecting proxy returns false on verification failure.
    function test_verifyPayload_ReturnsFalse_OnDenial() public {
        OrgDelegateHandler rejectingHandler = new OrgDelegateHandler(mockMasterControlProxyReject);
        bytes memory payload = abi.encode(uint256(42));

        bool result = rejectingHandler.verifyPayload(payload);
        assertFalse(result, "Should return false on policy denial");
    }

    /// @notice Test that different handlers can have different proxy addresses.
    function test_MultipleHandlers_DifferentProxies() public {
        OrgDelegateHandler handler1 = new OrgDelegateHandler(mockMasterControlProxy);
        OrgDelegateHandler handler2 = new OrgDelegateHandler(mockMasterControlProxyReject);

        assertNotEq(
            handler1.masterControlProxy(), handler2.masterControlProxy(), "Handlers should have different proxies"
        );
    }
}

/// @title MockMasterControlProxyAccept
/// @notice Mock implementation that always allows transactions.
contract MockMasterControlProxyAccept is IMasterControl {
    function verifyAndEnforce(bytes calldata payload) external pure override returns (bool) {
        return true;
    }
}

/// @title MockMasterControlProxyReject
/// @notice Mock implementation that always rejects transactions.
contract MockMasterControlProxyReject is IMasterControl {
    function verifyAndEnforce(bytes calldata payload) external pure override returns (bool) {
        return false;
    }
}
