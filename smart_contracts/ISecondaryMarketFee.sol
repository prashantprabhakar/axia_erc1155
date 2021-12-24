// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface ISecondaryMarketFees {

  struct Fee {
    address recipient;
    uint256 value;
  }
  
  function getFeeRecipients(uint256 tokenId) external view returns(address[] memory);

  function getFeeBps(uint256 tokenId) external view returns(uint256[] memory);


}