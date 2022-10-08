// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract PreCommitManager {
    using SafeERC20 for IERC20;

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

    // projectId => project creator
    mapping(uint256 => Project) public projects;
    // commitId => commit creator
    mapping(uint256 => Commit) public commits;

    uint256 lastProjectId;
    uint256 lastCommitId;

    event ProjectCreated(uint256 projectId, address creator);
    event FundsPulledForProject(uint256 projectId, address creator, uint256 totalAmount);
    event RedeemFailed(uint256 projectId, uint256 commitId, uint256 amount);
    event RedeemSucceeded(uint256 projectId, uint256 commitId, uint256 amount);
    event CommitCreated(uint256 commitId, uint256 projectId, address commiter, address erc20Token, uint256 amount, uint256 expiry);
    event CommitWithdrawn(uint256 commitId, address commiter);

    constructor() {}

    function createProject(address projectAcceptedAsset) public {
        lastProjectId++;
        projects[lastProjectId] = Project({receiver: msg.sender, asset: projectAcceptedAsset});

        emit ProjectCreated(lastProjectId, msg.sender);
    }

    function redeem(uint256 projectId, uint256[] memory commitIds) public {
        require(projects[projectId].receiver == msg.sender, "Only project creator can pull funds for the project");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < commitIds.length; i++) {
            Commit memory commit_ = commits[commitIds[i]];
            Project memory project = projects[commit_.projectId];
            require(commit_.projectId == projectId, "Commit does not belong to the project");
            require(project.receiver == msg.sender, "Commit does not belong to the project");
            require(commit_.expiry > block.timestamp, "Commit expired");

            bool success = IERC20(commit_.erc20Token).transferFrom(commit_.commiter, project.receiver, commit_.amount);
            if (success) {
                totalAmount += commit_.amount;
                delete commits[commitIds[i]];
                emit RedeemSucceeded(projectId, commit_.commitId, commit_.amount);
            } else {
                emit RedeemFailed(projectId, commit_.commitId, commit_.amount);
            }
        }
        
        emit FundsPulledForProject(projectId, msg.sender, totalAmount);
    }

    function commit(uint256 projectId, uint256 amount, uint256 deadline) public {
        require(amount > 0, "Amount must be greater than 0");
        require(deadline > block.timestamp, "Deadline must be in the future");

        // if token is not projectAcceptedAsset, allow approve and swap upon pulling
        address asset = projects[projectId].asset;
        IERC20(asset).safeApprove(address(this), amount);        
        // increment commit data
        lastCommitId++;
        Commit memory commitData = Commit({
            commitId: lastCommitId,
            projectId: projectId,
            commiter: msg.sender,
            erc20Token: asset,
            amount: amount,
            expiry: deadline
        });
        commits[lastCommitId] = commitData;

        emit CommitCreated(lastCommitId, projectId, msg.sender, asset, amount, deadline);
    }

    function withdrawCommit(uint256 commitId) public {
        require(commits[commitId].commiter == msg.sender, "Only commiter can withdraw");
        delete commits[commitId];

        emit CommitWithdrawn(commitId, msg.sender);
    }
}