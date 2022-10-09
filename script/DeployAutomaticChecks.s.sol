// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {PreCommitManager} from "src/PreCommitManager.sol";
import {CheckExpiring} from "src/CheckExpiring.sol";
import {CheckExpired} from "src/CheckExpired.sol";

contract DeployAutomaticChecks is Script {
    // global vars
    PreCommitManager preCommitManager;
    CheckExpiring checkExpiring;
    CheckExpired checkExpired;

    function run() external {
        uint256 admin = vm.envUint("ETH_KEYSTORE");
        vm.startBroadcast(admin);
        preCommitManager = PreCommitManager(
            0x8b76563670F37295d8756a4404D69d5BBa7c5dC8
        );
        //checkExpiring = new CheckExpiring(preCommitManager, 1200, 3600);
        //console.log("CheckExpiring: ", address(checkExpiring));
        checkExpired = new CheckExpired(preCommitManager);
        console.log("CheckExpired: ", address(checkExpired));
        vm.stopBroadcast();
    }
}
