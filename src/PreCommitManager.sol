// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IPreCommitManager.sol";

contract PreCommitManager is IPreCommitManager, Ownable {
    using SafeERC20 for IERC20;

    // projectId => project creator
    mapping(uint256 => Project) public projects;
    // commitId => commit creator
    mapping(uint256 => Commit) public commits;

    // automation address permitted to remove expired commits
    address public authorizedRemover;

    uint256 public lastProjectId;
    uint256 public lastCommitId;

    event ProjectCreated(uint256 projectId, address asset, address creator);
    event FundsRedeemedForProject(uint256 projectId, address creator);
    event RedeemFailed(uint256 projectId, uint256 commitId, uint256 amount);
    event RedeemSucceeded(uint256 projectId, uint256 commitId, uint256 amount);
    event CommitCreated(
        uint256 commitId,
        uint256 projectId,
        address commiter,
        address erc20Token,
        uint256 amount,
        uint256 expiry
    );
    event CommitWithdrawn(uint256 commitId, address commiter);

    function getProject(uint256 projectId)
        public
        view
        returns (Project memory)
    {
        return projects[projectId];
    }

    function getCommit(uint256 commitId) public view returns (Commit memory) {
        return commits[commitId];
    }

    function createProject(address projectAcceptedAsset) public {
        require(projectAcceptedAsset != address(0), "Invalid asset address");
        lastProjectId++;
        projects[lastProjectId] = Project({
            receiver: msg.sender,
            asset: projectAcceptedAsset
        });

        emit ProjectCreated(lastProjectId, projectAcceptedAsset, msg.sender);
    }

    function redeem(uint256 projectId, uint256[] memory commitIds) public {
        require(
            projects[projectId].receiver == msg.sender,
            "Only project creator can pull funds for the project"
        );

        for (uint256 i = 0; i < commitIds.length; i++) {
            Commit memory commit_ = commits[commitIds[i]];
            Project memory project = projects[commit_.projectId];
            require(
                commit_.projectId == projectId,
                "Commit does not belong to the project"
            );
            require(commit_.expiry > block.timestamp, "Commit expired");

            bool success = IERC20(commit_.erc20Token).transferFrom(
                commit_.commiter,
                project.receiver,
                commit_.amount
            );

            if (success) {
                delete commits[commitIds[i]];
                emit RedeemSucceeded(
                    projectId,
                    commit_.commitId,
                    commit_.amount
                );
            } else {
                emit RedeemFailed(projectId, commit_.commitId, commit_.amount);
            }
        }

        emit FundsRedeemedForProject(projectId, msg.sender);
    }

    function commit(
        uint256 projectId,
        uint256 amount,
        uint256 deadline
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(deadline > block.timestamp, "Deadline must be in the future");
        require(
            projects[projectId].receiver != address(0),
            "Project does not exist"
        );

        // if token is not projectAcceptedAsset, allow approve and swap upon pulling
        address asset = projects[projectId].asset;
        // check for allowance
        require(
            IERC20(asset).allowance(msg.sender, address(this)) >= amount,
            "address has not approved contract to use its funds"
        );

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

        emit CommitCreated(
            lastCommitId,
            projectId,
            msg.sender,
            asset,
            amount,
            deadline
        );
    }

    function withdrawCommit(uint256 commitId) public {
        require(
            (commits[commitId].commiter == msg.sender ||
                msg.sender == authorizedRemover),
            "Only committer or automation can withdraw"
        );
        delete commits[commitId];

        emit CommitWithdrawn(commitId, msg.sender);
    }

    function updateAuthorizedRemover(address authorizedRemover_)
        external
        onlyOwner
    {
        authorizedRemover = authorizedRemover_;
    }
}
