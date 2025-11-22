// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MasterContract} from "../src/MasterContract.sol";

contract CounterScript is Script {
    MasterContract public masterContract;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        masterContract = new MasterContract();

        vm.stopBroadcast();
    }
}
