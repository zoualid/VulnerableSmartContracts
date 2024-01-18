// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MetaTransactionContract {
    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }

    mapping(address => uint256) public nonces;

    event ExecutedMetaTransaction(
        address indexed from,
        address indexed relayer,
        bytes functionSignature,
        uint256 nonce,
        bool success
    );

    // The verify function as provided
    function verify(
        address signer,
        MetaTransaction memory metaTx,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) internal view returns (bool) {
        require(signer != address(0), "NativeMetaTransaction: INVALID_SIGNER");
        return
            signer ==
            ecrecover(
                toTypedMessageHash(hashMetaTransaction(metaTx)),
                sigV,
                sigR,
                sigS
            );  // <== vuln
    }

    // Hash the meta-transaction
    function hashMetaTransaction(MetaTransaction memory metaTx)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "MetaTransaction(uint256 nonce,address from,bytes functionSignature)"
                    ),
                    metaTx.nonce,
                    metaTx.from,
                    keccak256(metaTx.functionSignature)
                )
            );
    }

    // Create a typed message hash
    function toTypedMessageHash(bytes32 messageHash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    getDomainSeparator(),
                    messageHash
                )
            );
    }

    // Domain separator for EIP-712, which is used for structured data hashing and signing
    function getDomainSeparator() internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes("MetaTransactionContract")), // Name of the contract
                    keccak256(bytes("1")), // Version
                    getChainId(), // Chain ID
                    address(this)
                )
            );
    }

    function getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    // Function to execute a meta-transaction
    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) public returns (bytes memory) {
        MetaTransaction memory metaTx = MetaTransaction({
            nonce: nonces[userAddress],
            from: userAddress,
            functionSignature: functionSignature
        });

        require(
            verify(userAddress, metaTx, sigR, sigS, sigV),
            "MetaTransaction: INVALID_SIGNATURE"
        );

        nonces[userAddress]++;

        // Execute the transaction
        (bool success, bytes memory data) = address(this).delegatecall(
            abi.encodePacked(functionSignature, userAddress)
        );

        require(success, "MetaTransaction: FAILED_EXECUTION");

        emit ExecutedMetaTransaction(
            userAddress,
            msg.sender,
            functionSignature,
            nonces[userAddress] - 1,
            success
        );

        return data;
    }

    // Example function that could be called via meta-transaction
    function setValue(uint256 newValue) public {
        // Logic to set some value
    }
}
