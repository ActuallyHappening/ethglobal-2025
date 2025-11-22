// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

contract ProxyMasterContract {
    address public master;
    address public currentlyPointing;

    // Constructor code is only run when the contract
    // is created
    constructor() {
        // master is creator
        master = msg.sender;
    }

    function updateCurrentlyPointing(address newMasterContract) public {
        currentlyPointing = newMasterContract;
    }

    // what happens when this is run?
}
