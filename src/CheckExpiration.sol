// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "./IPreCommitManager.sol";

contract CheckExpiration {
    IPreCommitManager public immutable preCommitManager;
    uint256 internal _lastCheckTime;

    event CommitExpired(uint256 commitId);
    event CommitExpiringWarning(uint256 commitId);

    constructor(IPreCommitManager preCommitManager_) {
        preCommitManager = preCommitManager_;
    }

    function everyHour() external {
        if (_lastCheckTime != 0) {
            uint256 _nextCheckTime = _lastCheckTime + 3600;
            require(
                block.timestamp >= _nextCheckTime,
                "CheckExpiration: before next check time"
            );
            _checkExpiration();
            _lastCheckTime = _nextCheckTime;
        } else {
            // execute the first time
            _checkExpiration();
            _lastCheckTime = block.timestamp;
        }
    }

    function _checkExpiration() internal {
        for (uint256 i = 0; i < preCommitManager.lastCommitId() + 1; i++) {
            _checkExpiration(i);
        }
    }

    function _checkExpiration(uint256 commitId) internal {
        uint256 expiry = preCommitManager.getCommit(commitId).expiry;
        if (expiry == 0) {
            // commit already withdrawn
        } else if (
            expiry < block.timestamp + 3600 && expiry > block.timestamp
        ) {
            // expiring in less than 1 hour
            emit CommitExpiringWarning(commitId);
        } else if (expiry < block.timestamp) {
            emit CommitExpired(commitId);
        }
    }
}
