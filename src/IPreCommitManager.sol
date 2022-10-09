// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

interface IPreCommitManager {
    struct Project {
        address receiver;
        address asset;
    }
    struct Commit {
        uint256 commitId;
        uint256 projectId;
        address commiter;
        address erc20Token;
        uint256 amount;
        uint256 expiry;
    }

    function lastProjectId() external view returns (uint256);

    function lastCommitId() external view returns (uint256);

    function getProject(uint256) external view returns (Project memory);

    function getCommit(uint256) external view returns (Commit memory);

    function createProject(
        address,
        uint256,
        uint256,
        uint256[8] calldata
    ) external;

    function redeem(uint256 projectId, uint256[] memory commitIds) external;

    function commit(
        uint256 projectId,
        uint256 amount,
        uint256 deadline
    ) external;

    function withdrawCommit(uint256 commitId) external;
}
