// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract MintMockUSDC is Script {
    // global vars
    ERC20Mock usdc;

    function run() external {
        vm.startBroadcast();

        usdc = ERC20Mock(0x7D26526DedC4C3aB56B2d652AE5a75181D92bd2c);

        usdc.mint(0x2EE768CcCC8Dd06d6b90cf1E40301A19f0fc67d5, 100e18);

        vm.stopBroadcast();
    }
}
