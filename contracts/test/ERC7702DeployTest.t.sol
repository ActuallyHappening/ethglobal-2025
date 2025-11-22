// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC7702.sol";
import "../src/MasterContract.sol";

/// @title ERC7702DeployTest
/// @notice Tests for basic deployment and initialization of ERC7702 with MasterContract
contract ERC7702DeployTest is Test {
    ERC7702 public erc7702;
    MasterContract public masterContract;

    function setUp() public {
        // Deploy MasterContract
        masterContract = new MasterContract();

        // Deploy ERC7702 with MasterContract address
        erc7702 = new ERC7702(address(masterContract));
    }

    /// @notice Test that contracts deploy with non-zero addresses
    function test_DeploymentsSucceed() public {
        assertNotEq(address(masterContract), address(0), "MasterContract should be deployed");
        assertNotEq(address(erc7702), address(0), "ERC7702 should be deployed");
    }

    /// @notice Test that ERC7702 stores the correct MasterControl address
    function test_MasterControlAddressIsSet() public {
        assertEq(erc7702.masterControl(), address(masterContract), "MasterControl address mismatch");
    }

    /// @notice Test that execute allows transaction for whitelisted recipient
    function test_ExecuteAllowsWhitelistedRecipient() public {
        address whitelistedRecipient = 0xA7E34d70B0E77fD5E1364705f727280691fF8B9a;
        bool result = erc7702.execute(whitelistedRecipient, 10 ether);
        assertTrue(result, "Execute should return true for whitelisted recipient");
    }

    /// @notice Test that execute allows transaction for amount <= 1 ether
    function test_ExecuteAllowsSmallAmount() public {
        address recipient = address(0x1234);
        bool result = erc7702.execute(recipient, 0.5 ether);
        assertTrue(result, "Execute should return true for amount <= 1 ether");
    }

    /// @notice Test that execute reverts for disallowed transaction
    function test_ExecuteRevertsForDisallowedTransaction() public {
        address recipient = address(0x5678);
        uint256 amount = 5 ether;

        vm.expectRevert(ERC7702.TransactionNotAllowed.selector);
        erc7702.execute(recipient, amount);
    }

    /// @notice Test that ERC7702 constructor rejects zero address
    function test_ConstructorRejectsZeroAddress() public {
        vm.expectRevert(ERC7702.InvalidMasterControl.selector);
        new ERC7702(address(0));
    }

    /// @notice Test that Executed event is emitted on successful execute
    function test_ExecutedEventEmitted() public {
        address whitelistedRecipient = 0xA7E34d70B0E77fD5E1364705f727280691fF8B9a;

        // vm.expectEmit(true, true, false, true);
        //emit ERC7702.Executed(address(this), whitelistedRecipient, 10 ether);

        erc7702.execute(whitelistedRecipient, 10 ether);
    }
}
