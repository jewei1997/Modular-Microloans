// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {PreCommitManager} from "src/PreCommitManager.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract Deploy is Script {
    // global vars
    PreCommitManager public preComManager;
    ERC20Mock public usdc;

    function run() external {
        uint256 admin = vm.envUint("ETH_KEYSTORE");
        vm.startBroadcast(admin);

        address worldId = 0xABB70f7F39035586Da57B3c8136035f87AC0d2Aa;
        uint256 groupId = 1;
        string memory actionId = "wid_staging_e98527aa60da41d731308fe094997c9c";

        preComManager = new PreCommitManager(worldId, groupId, actionId);
        console.log("PreCommitManager: ", address(preComManager));

        // setup for populating the graph

        // deploy mock USDC
        usdc = ERC20Mock(0x7D26526DedC4C3aB56B2d652AE5a75181D92bd2c);
        // // allowance so precommit manager to use addresss usdc funds
        // usdc.approve(address(preComManager), initialAmount);
        vm.stopBroadcast();

        // // user 1 creates project 1
        // uint256 user1PrivateKey = vm.envUint("ADDRESS_USER");
        // vm.startBroadcast(user1PrivateKey);

        // uint256 root = 0x007c4dd879b2f2052f3810817e6648ca4a8f4b92e4e4bbe033552c1f25551a2b;
        // uint256 nullifierHash = 0x056e3c4fab95f8a0de91af0ff76d99f0773deddeceed9f984d2522e6118dbbe1;
        // uint256[8] memory proof = [
        //     21713195003532099063222572121794090601707849887786873140599517812500128389454,
        //     5133689745698018887047134261937513834983155291253340763430423465110831376207,
        //     5128396118166270817978920704624727061200191853627507212972272262606385125893,
        //     7588503123969815801210662314860634706207158687585233255664084239346931617334,
        //     7249019221027851865867418721763267189893921356406448070367920006343726538160,
        //     15032697336568716715532601246681629700335785041172513172998890325657204831115,
        //     5119868636201734617562558571815544918729419252574379926034913385603072968019,
        //     13021991777763969939779687472524954676447007296568336349805900910693620397908
        // ];

        // // create project with id 1
        // preComManager.createProject(address(usdc), root, nullifierHash, proof);
        // vm.stopBroadcast();

        // // user 2 commits to project 1
        // uint256 user2PrivateKey = vm.envUint("ADDRESS_USER_2");
        // vm.startBroadcast(user2PrivateKey);
        // // add funds to user2
        // uint256 user2AmountToCommit = 50e18;
        // usdc.mint(msg.sender, user2AmountToCommit);
        // usdc.approve(address(preComManager), user2AmountToCommit);
        // // commit to the project
        // preComManager.commit({
        //     projectId: 1,
        //     amount: user2AmountToCommit,
        //     deadline: block.timestamp + 1 weeks
        // });
        // vm.stopBroadcast();
    }
}
