// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {CheckExpiring} from "src/CheckExpiring.sol";
import {PreCommitManager} from "src/PreCommitManager.sol";

contract CheckExpiringDeploy is Script {
    // global vars
    PreCommitManager preComManager;
    CheckExpiring cEx;

    function run() external {
        uint256 admin = vm.envUint("ETH_KEYSTORE");
        vm.startBroadcast(admin);
        preComManager = PreCommitManager(
            0x80F7b90C88A80eE1e60e74Ce0c6207DfcA2E182C
        );
        cEx = new CheckExpiration(preComManager);
        console.log("CheckExpiration: ", address(cEx));
        vm.stopBroadcast();
    }
}
