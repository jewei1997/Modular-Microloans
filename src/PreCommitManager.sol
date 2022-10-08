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
    event FundsPulledForProject(uint256 projectId, address creator, uint256 amount);
    event CommitCreated(uint256 commitId, uint256 projectId, address commiter, address erc20Token, uint256 amount, uint256 expiry);
    event CommitWithdrawn(uint256 commitId, address commiter);

    constructor() {
        lastProjectId = 0;
        lastCommitId = 0;
    }

    function createProject(address projectAcceptedAsset) public {
        lastProjectId++;
        projects[lastProjectId] = Project({receiver: msg.sender, asset: projectAcceptedAsset});

        emit ProjectCreated(lastProjectId, msg.sender);
    }

    // function cancelProject(uint256 projectId) public {
    //     require(projects[projectId] == msg.sender, "Only project creator can cancel the project");
    //     preCommits[msg.sender] = 0;

    //     emit ProjectCancelled(projectId, msg.sender);
    // }

    // function isProjectActive(uint256 projectId) public view returns (bool) {
    //     return projects[projectId] != address(0);
    // }

    // function pullFundsForProject(uint256 projectId) public {
    //     require(projects[projectId] == msg.sender, "Only project creator can pull funds for the project");
    //     uint256 totalAmount = projectRaisedFunds[projectId];
    //     projectRaisedFunds[projectId] = 0;
        
    //     IERC20(commitData.erc20Token).safeTransfer(msg.sender, totalAmount);
        
    //     emit FundsPulledForProject(projectId, msg.sender, totalAmount);
    // }

    function commit(uint256 projectId, address token, uint256 amount, uint256 deadline) public {
        require(amount > 0, "Amount must be greater than 0");
        require(deadline > block.timestamp, "Deadline must be in the future");

        // if token is not projectAcceptedAsset, allow approve and swap upon pulling
        IERC20(token).safeApprove(address(this), amount);        
        // increment commit data
        lastCommitId++;
        Commit memory commitData = Commit({
            commitId: lastCommitId,
            projectId: projectId,
            commiter: msg.sender,
            erc20Token: token,
            amount: amount,
            expiry: deadline
        });
        commits[lastCommitId] = commitData;

        emit CommitCreated(lastCommitId, projectId, msg.sender, token, amount, deadline);
    }

    function withdrawCommit(uint256 commitId) public {
        require(commits[commitId].commiter == msg.sender, "Only commiter can withdraw");
        delete commits[commitId];

        emit CommitWithdrawn(commitId, msg.sender);
    }
}