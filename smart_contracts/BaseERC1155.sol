// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155.sol";
import "./Freezable.sol";

contract BaseERC1155 is ERC1155, Freezable {

    constructor(string memory uri) ERC1155(uri) {}

    /**
     * @dev See {ERC1155-safeTransferFrom}.
     *
     * Requirements:
     *
     * - `from` must be unfreezed
     * - `to` must be unfreezed
     * -  Contract should not be under emergency freeze
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
        isUnfreezed(from)
        isUnfreezed(to)
        noEmergencyFreeze
    {
        super.safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {ERC1155-safeBatchTransferFrom}.
     *
     * Requirements:
     *
     * - `from` must be unfreezed
     * - `to` must be unfreezed
     * -  Contract should not be under emergency freeze
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
        isUnfreezed(from)
        isUnfreezed(to)
        noEmergencyFreeze
    {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev See {HasTokenURI-_setTokenURIPrefix}.
     *
     * Requirements:
     *
     * - onlyOwner is allowed to call this function
     */
    function setTokenURIPrefix(string memory tokenURIPrefix) public onlyOwner {
        _setTokenURIPrefix(tokenURIPrefix);
    }

    /**
     * @dev Public function to set the token URI for a given token.
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to set its URI
     * @param uri string URI to assign

     * Requirements:
     *
     * - onlyAdmin is allowed to call this function
     * - tokenId shoudld already exist
     */
    function setTokenURI(uint256 tokenId, string memory uri)
        public
        onlyAdmin
        shouldExist(tokenId)
    {
        super._setTokenURI(tokenId, uri);
    }

    /**
     * @dev See {ERC1155-_burn}.
     */
    function burn(
        address from,
        uint256 id,
        uint256 amount
    ) public {
        _burn(from, id, amount);
    }

    /**
     * @dev See {ERC1155-_burnBatch}.
     */
    function burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public {
        _burnBatch(from, ids, amounts);
    }
}
