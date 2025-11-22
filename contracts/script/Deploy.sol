// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MasterContract} from "../src/MasterContract.sol";
import {EIP7702} from "../src/EIP7702.sol";

contract MasterScript is Script {
    MasterContract public masterContract;
    EIP7702 public eip7702Contract;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        masterContract = new MasterContract();
        console.log("Deployed master contract at: ", address(masterContract));
        
        eip7702Contract = new EIP7702(address(masterContract));

        vm.stopBroadcast();
    }
}
