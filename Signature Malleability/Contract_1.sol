// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleTokenTransfer {
    mapping(address => uint256) public balances;

    function transferWithSignature(
        address to, uint256 amount, bytes32 hash, bytes memory signature
    ) public {
        require(verify(msg.sender, hash, signature), "Invalid or unauthorized signature");
        
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    function verify(address signer, bytes32 hash, bytes memory signature) internal pure returns (bool) {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid recovery byte");

        return signer == ecrecover(hash, v, r, s);
    }
}
