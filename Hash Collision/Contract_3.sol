// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AgreementRegistry {
    struct Agreement {
        bytes32 id;
        bytes32 partyA;
        bytes32 partyB;
        string terms;
        bool isSigned;
    }

    mapping(bytes32 => Agreement) public agreements;

    event AgreementCreated(bytes32 indexed id, bytes32 indexed partyA, bytes32 indexed partyB);
    event AgreementSigned(bytes32 indexed id);

    // Create a new agreement
    function createAgreement(
        bytes32 partyA,
        bytes32 partyB,
        string memory terms
    ) public {
        bytes32 id = keccak256(
            abi.encodePacked(
                partyA,
                partyB
            )
        );

        agreements[id] = Agreement({
            id: id,
            partyA: partyA,
            partyB: partyB,
            terms: terms,
            isSigned: false
        });

        emit AgreementCreated(id, partyA, partyB);
    }

    // Sign an agreement
    function signAgreement(bytes32 agreementId,bytes32 user1) public {
        require(agreements[agreementId].id == agreementId, "Agreement does not exist");
        require(
            user1 == agreements[agreementId].partyA || user1 == agreements[agreementId].partyB,
            "Caller is not a party of this agreement"
        );

        agreements[agreementId].isSigned = true;

        emit AgreementSigned(agreementId);
    }

}
