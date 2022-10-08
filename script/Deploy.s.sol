// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {PreCommitManager} from "src/PreCommitManager.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        PreCommitManager preComManager = new PreCommitManager();

        console.log("PreCommitManager: %s", address(preComManager));

        vm.stopBroadcast();
    }
}
