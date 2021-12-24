// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

abstract contract ERC165 is IERC165 {

    bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;
    
    /**
    * 0x01ffc9a7 ===
    *   bytes4(keccak256('supportsInterface(bytes4)'))
    */

    /**
    * @dev a mapping of interface id to whether or not it's supported
    */
    mapping(bytes4 => bool) internal supportedInterfaces;

    /**
    * @dev A contract implementing SupportsInterfaceWithLookup
    * implement ERC165 itself
    */
    constructor()
    {
        _registerInterface(InterfaceId_ERC165);
    }

    /**
    * @dev implement supportsInterface(bytes4) using a lookup table
    */
    function supportsInterface(bytes4 _interfaceId)
        public
        override
        view
        returns (bool)
    {
        return supportedInterfaces[_interfaceId];
    }

    /**
    * @dev private method for registering an interface
    */
    function _registerInterface(bytes4 _interfaceId)
        internal
    {
        require(_interfaceId != 0xffffffff);
        supportedInterfaces[_interfaceId] = true;
    }
}