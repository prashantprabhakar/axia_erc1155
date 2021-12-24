// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./BaseERC1155.sol";
import "./SecondaryMarketFee.sol";

contract CustomERC1155 is BaseERC1155, SecondaryMarketFee {

  struct Signature {
    bytes32 r;
    bytes32 s;
    uint8 v;
  }

  constructor(string memory uri) BaseERC1155(uri) {
    //_registerInterface(_INTERFACE_ID_FEES);
  }

  function mint(
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data,
    string memory _uri,
    Fee[] memory _fees,
    Signature calldata adminSignature
  ) public returns(bool) {

    bytes32 signedMessage = keccak256(abi.encode(
      address(this),
      // add nonce as well
      // add chainId for replay protection
      to,
      id,
      amount,
      data
    ));
    require(isAdmin(getSigner(signedMessage, adminSignature)), "admin signature is required");
    _mint(to, id, amount, data, _uri);
    // @dev: check if fee is also dependent on quantity..
    super.addFees(id, _fees);
    return true;
  }

  function mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data,
    string[] memory _uris,
    Fee[] memory fees,  // fee is same for all ids..
    Signature calldata adminSignature
  ) public returns (bool) {

    bytes32 signedMessage = keccak256(abi.encode(
      address(this),
      // add nonce as well
      // add chainId for replay protection
      to,
      ids,
      amounts,
      data,
      fees
    ));
    require(isAdmin(getSigner(signedMessage, adminSignature)), "admin should sign tokenId");
    _mintBatch(to, ids, amounts, data, _uris);
    for (uint256 i = 0; i < ids.length; i++) {
      super.addFees(ids[i], fees);
    }
    return true;

  }


  function kill(uint message) external onlyOwner {
    require (message == 123456789987654321, "Invalid code");
    // Transfer Eth to owner and terminate contract
    selfdestruct(payable(msg.sender));
  }


  function getSigner(bytes32 message, Signature calldata sig) public pure returns (address){
    bytes memory prefix = "\x19Ethereum Signed Message:\n32";
    return ecrecover(keccak256(abi.encodePacked(prefix, message)),sig.v, sig.r, sig.s);
  }

}