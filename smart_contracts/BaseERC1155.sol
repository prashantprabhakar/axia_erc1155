// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155.sol";

contract BaseERC1155 is ERC1155, Ownable {
  
  constructor(string memory uri) ERC1155(uri) {
  }

  function directMint(
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data,
    string memory _uri
  ) public onlyOwner {
    _mint(to, id, amount, data, _uri);
  }

  function directMintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data,
    string[] memory _uris
  ) public onlyOwner {
    _mintBatch(to, ids, amounts, data, _uris);
  }

  function setTokenURIPrefix(string memory tokenURIPrefix) public onlyOwner {
    _setTokenURIPrefix(tokenURIPrefix);
  }

  /**
    * @dev Internal function to set the token URI for a given token.
    * Reverts if the token ID does not exist.
    * @param tokenId uint256 ID of the token to set its URI
    * @param uri string URI to assign
    */
  function setTokenURI(uint256 tokenId, string memory uri) public {
    //require(creators[tokenId] != address(0x0), "_setTokenURI: Token should exist");
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