// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

contract PreCommitManager is EIP712, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // address => bitmap holding used nonces, i.e. redeemed funds
    mapping(address => BitMaps.BitMap) internal usedNonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address asset,address beneficiary,uint256 amount,uint256 nonce,uint256 deadline)"
        );

    event PreCommitFundsRedeemed(
        address asset,
        address beneficiary,
        uint256 amount,
        uint256 nonce
    );

    modifier requireNonZero(address asset, uint256 amount) {
        require(asset != address(0), "asset not set");
        require(amount > 0, "amount is zero");

        _;
    }

    constructor() EIP712("PreCommitManager", "1") {}

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    /// @dev Withdraw ERC20 from precommiter
    /// @param asset the address of the asset to be redeemed.
    /// @param amount the amount of the redeem
    /// @param nonce the user nonce for redeem.
    /// @param deadline the number of the last block where the redeem is accepted.
    /// @param signature ECDSA signature.
    function redeemFromPreCommiter(
        address asset,
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        bytes memory signature
    ) external nonReentrant requireNonZero(asset, amount) {
        require(block.number <= deadline, "expired deadline");

        address beneficiary = msg.sender;

        // nonce was not used before
        require(!BitMaps.get(usedNonces[beneficiary], nonce), "Invalid nonce");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                asset,
                beneficiary,
                amount,
                nonce,
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, signature);
        // require(signer == precommiter, "invalid signature");

        // mark nonce as being used
        BitMaps.set(usedNonces[beneficiary], nonce);

        _redeemFromPreCommiter(signer, asset, beneficiary, amount, nonce);
    }

    /// private functions
    function _redeemFromPreCommiter(
        address _precommitter,
        address _asset,
        address _beneficiary,
        uint256 _amount,
        uint256 _nonce
    ) private requireNonZero(_asset, _amount) {
        IERC20(_asset).safeTransferFrom(_precommitter, _beneficiary, _amount);
        // Here is the part that would be modular ???

        // end of the modular call
        emit PreCommitFundsRedeemed(_asset, _beneficiary, _amount, _nonce);
    }
}