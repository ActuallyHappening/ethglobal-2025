// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

contract MasterContract {
    function verify(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) public pure returns (bool) {
        if (recipient == 0xA7E34d70B0E77fD5E1364705f727280691fF8B9a) {
            return true;
        }
        if (amount <= 1 ether) {
            return true;
        }
        if (data.length != 0) {
            // return true;
        }
        return false;
    }
}
