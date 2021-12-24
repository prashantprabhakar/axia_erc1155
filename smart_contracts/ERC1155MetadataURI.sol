// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./HasTokenURI.sol";

/**
    Note: The ERC-165 identifier for this interface is 0x0e89341c.
*/
abstract contract ERC1155MetadataURI is HasTokenURI {

    constructor(string memory _tokenURIPrefix) HasTokenURI(_tokenURIPrefix) {

    }

    function uri(uint256 _id) external view returns (string memory) {
        return _tokenURI(_id);
    }
}