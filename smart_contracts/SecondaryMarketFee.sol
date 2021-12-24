// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./ISecondaryMarketFee.sol";
import "./Ownership.sol";


contract SecondaryMarketFee is ISecondaryMarketFees, Ownership {

  address public ownerContract;
  uint256 public decimals;

  mapping (uint256 => Fee[]) public fees;

  /*
    * bytes4(keccak256('getFeeBps(uint256)')) == 0x0ebd4c7f
    * bytes4(keccak256('getFeeRecipients(uint256)')) == 0xb9c4d9fb
    *
    * => 0x0ebd4c7f ^ 0xb9c4d9fb == 0xb7799584
    */
  bytes4 public constant _INTERFACE_ID_FEES = 0xb7799584;

  event SecondarySaleFees(uint256 tokenId, Fee[] _fees);

  constructor() {
    decimals = 3; // this makes min fee to be 0.001% for any recipient
  }


  /**
   * @dev Get fee recipients when asset is sold in secondary market
   * @param tokenId Id of NFT for which fee recipients are to be fetched
   * @return array of addresses that'll recieve the commission when sold in secondary market
   */
  function getFeeRecipients(uint256 tokenId) public override view returns(address[] memory) {
    Fee[] memory _fees = fees[tokenId];
    address[] memory _recipients = new address[](_fees.length);
    for(uint256 i=0;  i<_fees.length; i++) {
      _recipients[i] = _fees[i].recipient;
    }
    return _recipients;
  }


  /**
   * @dev Get fee values when asset is sold in secondary market
   * @param tokenId Id of NFT for which fee values are to be fetched
   * @return array of fees percentages that'll the recipients wil get when sold in secondary market
   */
  function getFeeBps(uint256 tokenId) public override view returns(uint256[] memory) {
    Fee[] memory _fees = fees[tokenId];
    uint256[] memory _values = new uint256[](_fees.length);
    for(uint256 i=0;  i<_fees.length; i++) {
      _values[i] = _fees[i].value;
    }
    return _values;
  }

  /**
   * @dev Add fees (address and percentage) for a tokenId
   * @param tokenId Id of NFT for which fee values are to be added
   * @param _fees Fee struct (with address and fee percentage) for given `tokenId`
   * @dev array of fees percentages that'll the recipients wil get when sold in secondary market
   */
  function addFees(uint256 tokenId, Fee[] memory _fees) internal {
    uint256 totalPercentage = 0;
    for (uint256 i = 0; i < _fees.length; i++) {
      require(_fees[i].recipient != address(0x0), "Recipient should be present");
      require(_fees[i].value != 0, "Fee value should not be zero");
      totalPercentage += _fees[i].value;
      fees[tokenId].push(_fees[i]);
    }
    require(totalPercentage < 100 * 10 ** decimals, "percentage should be max 100");
    emit SecondarySaleFees(tokenId, _fees);
  }

  function removeFees(uint256 tokenId) internal {
    delete(fees[tokenId]);
  }


}