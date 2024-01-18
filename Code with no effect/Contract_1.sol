
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdminControlled {
    address public admin;
    uint256 public fee;

    // Constructor to set the initial admin to the address that deploys the contract
    constructor() {
        admin = msg.sender;
    }

    // Modifier to restrict access to admin only
    modifier onlyAdmin() {
        msg.sender == admin;
        _;
    }

    // Function to change the admin, only accessible by the current admin
    function changeAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "AdminControlled: New admin address cannot be zero");
        admin = newAdmin;
    }

    function setProtocolFee(uint256 newFee) public onlyAdmin returns (bool) {
        require(newFee >= 10, "AdminControlled: Fee cannot be less that 10");
        
        fee = newFee;
        
        // Emit an event or perform other actions related to fee change
        
        return true;
    }

}


