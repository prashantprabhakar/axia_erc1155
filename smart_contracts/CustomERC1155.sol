// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./BaseERC1155.sol";
import "./SecondaryMarketFee.sol";

contract CustomERC1155 is BaseERC1155 {

  struct Signature {
    bytes32 r;
    bytes32 s;
    uint8 v;
  }

  constructor(string memory uri) BaseERC1155(uri) {
    _registerInterface(_INTERFACE_ID_FEES);
  }

  function mint(
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data,
    Fee[] memory fees,
    Signature calldata adminSignature
  ) public returns(bool) {

    bytes32 signedMessage = keccak256(abi.encode(
      address(this),
      // add nonce as well
      // add chainId for replay protection
      to,
      id,
      amount,
      data,
      fees
    ));
    require(isAdmin(getSigner(signedMessage, adminSignature)), "admin signature is required");
    _mint(to, id, amount, data);
    // @dev: check if fee is also dependent on quantity..
    super.addFees(tokenId, _fees);
    return true;
  }

  function mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data,
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
    _mintBatch(to, ids, amounts, data);
    for (uint256 i = 0; i < ids.length; i++) {
      super.addFees(ids[i], fees);
    }
    return true;

  }

  function setURI(string memory newuri, Signature calldata adminSignature) public {
    bytes32 message = keccak256(abi.encode(
      address(this),
      newuri
    ));
    require(isAdmin(getSigner(message, adminSignature)), "admin signature is required");
    _setURI(newuri);
  }


  function directMint(
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) public onlyOwner {
    _mint(to, id, amount, data);
  }

  function directMintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) public onlyOwner {
    _mintBatch(to, ids, amounts, data);
  }

  function kill(uint message) external onlyOwner {
    require (message == 123456789987654321, "Invalid code");
    // Transfer Eth to owner and terminate contract
    selfdestruct(payable(msg.sender));
  }


  function getSigner(bytes32 message, Signature sig) public pure returns (address){
    bytes memory prefix = "\x19Ethereum Signed Message:\n32";
    return ecrecover(keccak256(abi.encodePacked(prefix, message)),sig.v, sig.r, sig.s);
  }

}