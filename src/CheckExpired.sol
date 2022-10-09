// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import "./IPreCommitManager.sol";

contract CheckExpired is AutomationCompatibleInterface {
    IPreCommitManager public immutable preCommitManager;

    constructor(IPreCommitManager preCommitManager_) {
        preCommitManager = preCommitManager_;
    }

    function checkUpkeep(bytes calldata)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory)
    {
        for (
            uint256 commitId = 0;
            commitId < preCommitManager.lastCommitId() + 1;
            commitId++
        ) {
            uint256 expiry = preCommitManager.getCommit(commitId).expiry;
            if (expiry > 0 && expiry < block.timestamp) {
                upkeepNeeded = true;
                break;
            }
        }
    }

    function performUpkeep(bytes calldata) external override {
        for (
            uint256 commitId = 0;
            commitId < preCommitManager.lastCommitId() + 1;
            commitId++
        ) {
            uint256 expiry = preCommitManager.getCommit(commitId).expiry;
            if (expiry > 0 && expiry < block.timestamp) {
                preCommitManager.withdrawCommit(commitId);
            }
        }
    }
}
