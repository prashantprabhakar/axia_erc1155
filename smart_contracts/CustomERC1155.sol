// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./BaseERC1155.sol";
import "./SecondaryMarketFee.sol";

contract CustomERC1155 is BaseERC1155, SecondaryMarketFee {
    // A nonce value to prevent replay of same signed transaction.
    mapping(address => mapping(uint256 => bool)) public isNonceUsed;

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    constructor(string memory uri) BaseERC1155(uri) {
        _registerInterface(_INTERFACE_ID_FEES);
    }

    /**
     * @dev See {ERC1155-_mint}.
     *
     * Adds royality fee for secondary market sales to `id`
     * Requirements:
     *
     * - Only Admin is allowed to call the function
     * - `to` must be unfreezed
     */
    function directMint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data,
        string memory _uri,
        Fee[] memory _fees
    ) public onlyAdmin isUnfreezed(to) {
        _mint(to, id, amount, data, _uri);
        super.addFees(id, _fees);
    }

    /**
     * @dev See {ERC1155-_mintBatch}.
     *
     * Adds royality fee for secondary market sales to all `ids`
     * Requirements:
     *
     * - Only Admin is allowed to call the function
     * - `to` must be unfreezed
     */
    function directMintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data,
        string[] memory _uris,
        Fee[] memory _fees
    ) public onlyAdmin isUnfreezed(to) {
        _mintBatch(to, ids, amounts, data, _uris);
        for (uint256 i = 0; i < ids.length; i++) {
            super.addFees(ids[i], _fees);
        }
    }

    /**
     * @dev See {ERC11-_mint}
     * Adds royality fee for secondary market sales to `id`
     *
     * Requirements:
     *
     * - Admin must sign the params of the function along with contract address, chainId and random nonce
     */
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data,
        string memory _uri,
        Fee[] memory _fees,
        Signature calldata adminSignature,
        uint256 customNonce
    ) public isUnfreezed(to) returns (bool) {
        bytes32 signedMessage = keccak256(
            abi.encode(
                address(this),
                customNonce,
                // add chainId for replay protection
                to,
                id,
                amount,
                data
            )
        );
        validateSigning(signedMessage, adminSignature, customNonce);
        _mint(to, id, amount, data, _uri);
        super.addFees(id, _fees);
        return true;
    }

    /**
     * @dev See {ERC1155-_mintBatch}.
     *
     * Adds royality fee for secondary market sales to all `ids`
     * Requirements:
     *
     * - Only Admin is allowed to call the function
     * - `to` must be unfreezed
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data,
        string[] memory _uris,
        Fee[] memory fees, // fee is same for all ids..
        Signature calldata adminSignature,
        uint256 customNonce
    ) public isUnfreezed(to) returns (bool) {
        bytes32 signedMessage = keccak256(
            abi.encode(
                address(this),
                customNonce,
                // add chainId for replay protection
                to,
                ids,
                amounts,
                data,
                fees
            )
        );
        validateSigning(signedMessage, adminSignature, customNonce);
        _mintBatch(to, ids, amounts, data, _uris);
        for (uint256 i = 0; i < ids.length; i++) {
            super.addFees(ids[i], fees);
        }
        return true;
    }

    /**
     * @dev Public function to set the token URI for a given token.
     *
     * Requirements:
     *
     * - Admin must sign the params of the function along with contract address, chainId and random nonce
     * - tokenId shoudld already exist
     */
    function setTokenURI(
        uint256 tokenId,
        string memory uri,
        Signature calldata adminSignature,
        uint256 customNonce
    ) public shouldExist(tokenId) {
        bytes32 signedMessage = keccak256(
            abi.encode(
                address(this),
                customNonce,
                // add chainId for replay protection
                tokenId,
                uri
            )
        );
        validateSigning(signedMessage, adminSignature, customNonce);
        super._setTokenURI(tokenId, uri);
    }

    /**
     * @dev See {ERC1155-_setApprovalForAll}
     *
     * Requirements:
     *
     * - Admin must sign the params of the function along with contract address, chainId and random nonce
     */
    function signedSetApprovalForAll(
        bool approved,
        Signature calldata userSignature,
        uint256 customNonce
    ) public {
        bytes32 signedMessage = keccak256(
            abi.encode(address(this), customNonce, approved)
        );
        address signer = getSigner(signedMessage, userSignature);
        require(!isFreezed(signer), "Signer is freezed");
        require(!isNonceUsed[signer][customNonce], "Nonce is already used");
        isNonceUsed[signer][customNonce] = true;
        _setApprovalForAll(_msgSender(), signer, approved);
    }

    /**
     * @dev Allows owner to destroy the contract.
     * MUST BE USED WITH UTMOST CARE.
     */
    function kill(uint256 message) external onlyOwner {
        require(message == 123456789987654321, "Invalid code");
        // Transfer Eth to owner and terminate contract
        selfdestruct(payable(msg.sender));
    }

    function getSigner(bytes32 message, Signature calldata sig)
        public
        pure
        returns (address)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return
            ecrecover(
                keccak256(abi.encodePacked(prefix, message)),
                sig.v,
                sig.r,
                sig.s
            );
    }

    function validateSigning(
        bytes32 signedMessage,
        Signature calldata adminSignature,
        uint256 customNonce
    ) private returns (address) {
        address signer = getSigner(signedMessage, adminSignature);
        require(!isFreezed(signer), "Signer is freezed");
        require(isAdmin(signer), "admin signature is required");
        require(!isNonceUsed[signer][customNonce], "Nonce is already used");
        isNonceUsed[signer][customNonce] = true;
        return signer;
    }
}
