// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155.sol";
import "./Freezable.sol";

contract BaseERC1155 is ERC1155, Freezable {
  
  constructor(string memory uri) ERC1155(uri) {
  }

  function directMint(
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data,
    string memory _uri
  )
    public
    onlyAdmin
    isUnfreezed(to)
  {
    _mint(to, id, amount, data, _uri);
  }

  function directMintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data,
    string[] memory _uris
  ) public onlyAdmin isUnfreezed(to) {
    _mintBatch(to, ids, amounts, data, _uris);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) isUnfreezed(from) isUnfreezed(to) public virtual override {
    super.safeTransferFrom(from, to, id, amount, data);
  }

  function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) isUnfreezed(from) isUnfreezed(to) public virtual override {
      super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

  function setTokenURIPrefix(string memory tokenURIPrefix) public onlyOwner {
    _setTokenURIPrefix(tokenURIPrefix);
  }

  /**
    * @dev Public function to set the token URI for a given token.
    * Reverts if the token ID does not exist.
    * @param tokenId uint256 ID of the token to set its URI
    * @param uri string URI to assign
    */
  function setTokenURI(uint256 tokenId, string memory uri) public onlyAdmin {
    super._setTokenURI(tokenId, uri);
  }


  function burn(
    address from,
    uint256 id,
    uint256 amount
  ) public {
    _burn(from, id, amount);
  }

  function burnBatch(
    address from,
    uint256[] memory ids,
    uint256[] memory amounts
  ) public {
    _burnBatch(from, ids, amounts);
  }

}