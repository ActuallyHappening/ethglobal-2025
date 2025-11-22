// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {EIP7702, Call} from "../src/EIP7702.sol";
import "../src/MasterContract.sol";

/// @title EIP7702DeployTest
/// @notice Tests for basic deployment and initialization of EIP7702 with MasterContract
contract EIP7702DeployTest is Test {
    EIP7702 public eip7702;
    MasterContract public masterContract;
    uint256 orgPrivateKey;

    function setUp() public {
        // Deploy MasterContract
        masterContract = new MasterContract();

        // Deploy EIP7702 with MasterContract address
        eip7702 = new EIP7702(address(masterContract), address(this));

        orgPrivateKey = vm.envOr("ORG_PK", uint256(0x0));
        console.log("Org pk:", orgPrivateKey);
        require(orgPrivateKey != 0, "Set ORG_PK in env");

        vm.signAndAttachDelegation(address(eip7702), orgPrivateKey);
    }

    /// @notice Test that contracts deploy with non-zero addresses
    function test_DeploymentsSucceed() public {
        assertNotEq(
            address(masterContract),
            address(0),
            "MasterContract should be deployed"
        );
        assertNotEq(address(eip7702), address(0), "EIP7702 should be deployed");
    }

    /// @notice Test that EIP7702 stores the correct MasterControl address
    function test_MasterControlAddressIsSet() public {
        assertEq(
            eip7702.verifyingContract(),
            address(masterContract),
            "MasterControl address mismatch"
        );
    }

    function successfulCalls() public pure returns (Call[] memory) {
        address whitelistedRecipient = 0xA7E34d70B0E77fD5E1364705f727280691fF8B9a;

        Call[] memory _successfulCalls = new Call[](1);

        _successfulCalls[0] = Call({
            to: whitelistedRecipient,
            value: 10 ether,
            data: ""
        });

        return _successfulCalls;
    }

    function test_VerifyAllSuccessfulCalls() public {
        Call[] memory array = successfulCalls();
        for (uint i = 0; i < array.length; i++) {
            Call memory call = array[i];
            require(eip7702.verify(call), "Call failed");
        }
    }

    /// @notice Test that execute allows transaction for whitelisted recipient
    function test_ExecuteAllowsWhitelistedRecipient() public {
        // vm.prank(vm.addr(orgPrivateKey));
        eip7702.execute(successfulCalls());
    }

    // /// @notice Test that execute allows transaction for amount <= 1 ether
    // function test_ExecuteAllowsSmallAmount() public {
    //     address recipient = address(0x1234);
    //     bool result = eip7702.execute(recipient, 0.5 ether);
    //     assertTrue(result, "Execute should return true for amount <= 1 ether");
    // }

    // /// @notice Test that execute reverts for disallowed transaction
    // function test_ExecuteRevertsForDisallowedTransaction() public {
    //     address recipient = address(0x5678);
    //     uint256 amount = 5 ether;

    //     vm.expectRevert(EIP7702.TransactionNotAllowed.selector);
    //     eip7702.execute(recipient, amount);
    // }

    // /// @notice Test that EIP7702 constructor rejects zero address
    // function test_ConstructorRejectsZeroAddress() public {
    //     vm.expectRevert(EIP7702.InvalidMasterControl.selector);
    //     new EIP7702(address(0));
    // }

    // /// @notice Test that Executed event is emitted on successful execute
    // function test_ExecutedEventEmitted() public {
    //     address whitelistedRecipient = 0xA7E34d70B0E77fD5E1364705f727280691fF8B9a;

    //     // vm.expectEmit(true, true, false, true);
    //     //emit EIP7702.Executed(address(this), whitelistedRecipient, 10 ether);

    //     eip7702.execute(whitelistedRecipient, 10 ether);
    // }
}
