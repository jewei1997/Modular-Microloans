// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IPreCommitManager.sol";
import {ByteHasher} from "./library/ByteHasher.sol";

interface IWorldID {
    /// @notice Reverts if the zero-knowledge proof is invalid.
    /// @param root The of the Merkle tree
    /// @param groupId The id of the Semaphore group
    /// @param signalHash A keccak256 hash of the Semaphore signal
    /// @param nullifierHash The nullifier hash
    /// @param externalNullifierHash A keccak256 hash of the external nullifier
    /// @param proof The zero-knowledge proof
    /// @dev  Note that a double-signaling check is not included here, and should be carried by the caller.
    function verifyProof(
        uint256 root,
        uint256 groupId,
        uint256 signalHash,
        uint256 nullifierHash,
        uint256 externalNullifierHash,
        uint256[8] calldata proof
    ) external view;
}

contract PreCommitManager is IPreCommitManager {
    using SafeERC20 for IERC20;
    using ByteHasher for bytes;

    // projectId => project creator
    mapping(uint256 => Project) public projects;
    // commitId => commit creator
    mapping(uint256 => Commit) public commits;
    // whether a nullifier hash has been used already. Used to prevent double-signaling
    mapping(uint256 => bool) internal nullifierHashes;

    // The World ID group whose participants can claim this airdrop
    uint256 internal immutable groupId;
    // The World ID Action ID
    uint256 internal immutable actionId;
    // semaphore contract for worldId
    IWorldID internal immutable worldId;

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

    constructor(
        address _worldId,
        uint256 _groupId,
        string memory _actionId
    ) {
        worldId = IWorldID(_worldId);
        groupId = _groupId;
        actionId = abi.encodePacked(_actionId).hashToField();
    }

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

    function createProject(
        address projectAcceptedAsset,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) public {
        // id check
        require(!nullifierHashes[nullifierHash], "hash already used");
        worldId.verifyProof(
            root,
            groupId,
            abi.encodePacked(msg.sender).hashToField(), // The signal of the proof
            nullifierHash,
            actionId,
            proof
        );

        nullifierHashes[nullifierHash] = true;

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
            require(
                project.receiver == msg.sender,
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
            commits[commitId].commiter == msg.sender,
            "Only commiter can withdraw"
        );
        delete commits[commitId];

        emit CommitWithdrawn(commitId, msg.sender);
    }
}
