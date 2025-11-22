// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {EIP7702} from "../src/EIP7702.sol";

contract MasterScript is Script {
    EIP7702 public eip7702Contract;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        eip7702 = new EIP7702();

        vm.stopBroadcast();
    }
}
