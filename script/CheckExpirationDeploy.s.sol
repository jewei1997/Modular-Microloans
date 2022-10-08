// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {CheckExpiration} from "src/CheckExpiration.sol";
import {PreCommitManager} from "src/PreCommitManager.sol";

contract CheckExpirationDeploy is Script {
    // global vars
    PreCommitManager preComManager;
    CheckExpiration cEx;

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
