// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {PreCommitManager} from "src/PreCommitManager.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract Deploy is Script {
    // global vars
    PreCommitManager preComManager;
    ERC20Mock usdc;

    function run() external {
        uint256 admin = vm.envUint("ETH_KEYSTORE");
        vm.startBroadcast(admin);
        preComManager = new PreCommitManager();
        console.log("PreCommitManager: ", address(preComManager));

        // setup for populating the graph

        // deploy mock USDC
        usdc = ERC20Mock(0x7D26526DedC4C3aB56B2d652AE5a75181D92bd2c);
        // // allowance so precommit manager to use addresss usdc funds
        // usdc.approve(address(preComManager), initialAmount);
        vm.stopBroadcast();

        // user 1 creates project 1
        uint256 user1PrivateKey = vm.envUint("ADDRESS_USER");
        vm.startBroadcast(user1PrivateKey);
        // create project with id 1
        preComManager.createProject(address(usdc));
        vm.stopBroadcast();

        // user 2 commits to project 1
        uint256 user2PrivateKey = vm.envUint("ADDRESS_USER_2");
        vm.startBroadcast(user2PrivateKey);
        // add funds to user2
        uint256 user2AmountToCommit = 50e18;
        usdc.mint(msg.sender, user2AmountToCommit);
        usdc.approve(address(preComManager), user2AmountToCommit);
        // commit to the project
        preComManager.commit({
            projectId: 1,
            amount: user2AmountToCommit,
            deadline: block.timestamp + 1 weeks
        });
        vm.stopBroadcast();
    }
}
