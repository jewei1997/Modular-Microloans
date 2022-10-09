// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {preCommitManager} from "src/preCommitManager.sol";
import {CheckExpiring} from "src/CheckExpiring.sol";
import {CheckExpired} from "src/CheckExpired.sol";

contract DeployAutomaticChecks is Script {
    // global vars
    preCommitManager preCommitManager;
    CheckExpiring checkExpiring;
    CheckExpired checkExpired;

    function run() external {
        uint256 admin = vm.envUint("ETH_KEYSTORE");
        vm.startBroadcast(admin);
        preCommitManager = preCommitManager(
            // UPDATE ADDRESS
            0x80F7b90C88A80eE1e60e74Ce0c6207DfcA2E182C
        );
        checkExpiring = new CheckExpiring(preCommitManager);
        console.log("CheckExpiring: ", address(checkExpiring));
        checkExpired = new CheckExpired(preCommitManager);
        console.log("CheckExpired: ", address(checkExpired));
        vm.stopBroadcast();
    }
}
