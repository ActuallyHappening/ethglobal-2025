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
        uint256 masterPrivateKey = vm.envOr("MASTER_PK", uint256(0x0));
        require(masterPrivateKey != 0, "Set MASTER_PK in env");

        uint256 orgPrivateKey = vm.envOr("ORG_PK", uint256(0x0));
        require(orgPrivateKey != 0, "Set ORG_PK in env");

        vm.startBroadcast(masterPrivateKey);

        masterContract = new MasterContract();
        console.log(
            unicode"Deployed master contract at: 📡",
            address(masterContract),
            unicode"📡"
        );

        
        eip7702Contract = new EIP7702(address(masterContract));

        vm.stopBroadcast();
    }
}
