// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IPreCommitManager.sol";

contract CheckExpiring is Ownable {
    IPreCommitManager public preCommitManager;
    uint256 public minimumInterval;
    uint256 public warningTime;

    uint256 internal _lastCheckTime;

    event CommitExpiringWarning(uint256 commitId);

    constructor(IPreCommitManager preCommitManager_) {
        preCommitManager = preCommitManager_;
    }

    function checkAtMinInterval() external {
        if (_lastCheckTime != 0) {
            uint256 _nextCheckTime = _lastCheckTime + minimumInterval;
            require(
                block.timestamp >= _nextCheckTime,
                "CheckExpiring: minimum interval between checks has not elapsed"
            );
            _lastCheckTime = _nextCheckTime;
        } else {
            // execute the first time
            _lastCheckTime = block.timestamp;
        }
    }

    function checkExpiration() public {
        for (
            uint256 commitId = 0;
            commitId < preCommitManager.lastCommitId() + 1;
            commitId++
        ) {
            _checkExpiration(commitId);
        }
    }

    function _checkExpiration(uint256 commitId) internal {
        uint256 expiry = preCommitManager.getCommit(commitId).expiry;
        if (expiry == 0) {
            // commit already withdrawn
        } else if (
            expiry < block.timestamp + warningTime && expiry > block.timestamp
        ) {
            // expiring in less than 1 hour
            emit CommitExpiringWarning(commitId);
        }
    }

    function setPreCommitManager(IPreCommitManager preCommitManager_)
        external
        onlyOwner
    {
        preCommitManager = preCommitManager_;
    }

    function setMinimumInterval(uint256 minimumInterval_) external onlyOwner {
        minimumInterval = minimumInterval_;
    }

    function setWarningTime(uint256 warningTime_) external onlyOwner {
        warningTime = warningTime_;
    }
}
