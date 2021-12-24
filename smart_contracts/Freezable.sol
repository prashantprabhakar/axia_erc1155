// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownership.sol";

/**
 * @title Freezable Contract
 * This contract allows the inherited contract to be freezed.
 * Most state update actions should be prohibted when contract is freezed.
 * Only admin can perform some actions including "unfreezing".
 * Use of Freezable modifiers entirely depends on parent contract
 */
contract Freezable is Ownership {
    
    bool public emergencyFreeze = false;
    mapping(address => bool) private _isFreezed;

    event EmerygencyFreezed(bool emergencyFreezeStatus);
    event Freezed(address user, bool isFreezed);

    modifier noEmergencyFreeze() { 
      require(!emergencyFreeze, "Contract is freezed");
      _; 
    }

    modifier isUnfreezed(address user) {
      require(!isFreezed(user), "Address is freezed");
      _;
    }

    /**
     * @dev Admin can freeze/unfreeze the contract
     * Reverts if sender is not the owner of contract
     * @param _freeze Boolean valaue; true is used to freeze and false for unfreeze
     */ 
    function emergencyFreezeAllAccounts (bool _freeze) public onlyOwner returns(bool) {
        emergencyFreeze = _freeze;
        emit EmerygencyFreezed(_freeze);
        return true;
    }

    function freezeUser(address user) public isUnfreezed(user) onlyOwner {
      _isFreezed[user] = true;
      emit Freezed(user, true);
    }

    function unfreeze(address user) public onlyOwner {
      require(isFreezed(user), "Address is not freezed");
      _isFreezed[user] = false;
      emit Freezed(user, false);
    }

    function isFreezed(address user) public view returns(bool) {
      return _isFreezed[user];
    }

}