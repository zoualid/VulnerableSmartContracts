// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract AccessControl {
    using ECDSA for bytes32;

    mapping(address => bool) public isAdmin;
    mapping(address => bool) public isRegularUser;

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event RegularUserAdded(address indexed user);
    event RegularUserRemoved(address indexed user);
    event PrivilegedActionExecuted(address indexed admin, string action);

    constructor() {
        isAdmin[msg.sender] = true;
    }

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "AccessControl: Caller is not an admin");
        _;
    }

    function addUsers(
        address[] calldata admins,
        address[] calldata regularUsers,
        bytes calldata signature
    ) external {
        if (!isAdmin[msg.sender]) {
            bytes32 hash = keccak256(abi.encodePacked(admins, regularUsers));  // <== vuln
            address signer = hash.toEthSignedMessageHash().recover(signature);
            require(isAdmin[signer], "AccessControl: Only admins can add users");
        }

        for (uint256 i = 0; i < admins.length; i++) {
            isAdmin[admins[i]] = true;
            emit AdminAdded(admins[i]);
        }
        for (uint256 i = 0; i < regularUsers.length; i++) {
            isRegularUser[regularUsers[i]] = true;
            emit RegularUserAdded(regularUsers[i]);
        }
    }

    function removeAdmin(address admin) external onlyAdmin {
        require(isAdmin[admin], "AccessControl: Not an admin");
        isAdmin[admin] = false;
        emit AdminRemoved(admin);
    }

    function removeRegularUser(address user) external onlyAdmin {
        require(isRegularUser[user], "AccessControl: Not a regular user");
        isRegularUser[user] = false;
        emit RegularUserRemoved(user);
    }

    function checkAdminStatus(address user) external view returns (bool) {
        return isAdmin[user];
    }

    function checkRegularUserStatus(address user) external view returns (bool) {
        return isRegularUser[user];
    }

    function executePrivilegedAction(string calldata action) external onlyAdmin {
        // Example privileged action
        emit PrivilegedActionExecuted(msg.sender, action);
        // Implement action logic here
    }

}
