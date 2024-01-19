// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    struct Vote {
        bool exists;
        mapping(address => bool) voted;
        mapping(bytes32 => uint256) results;
        bytes32[] candidateHashes;
    }

    mapping(bytes32 => Vote) public votes;

    // Creates a new vote
    function createVote(string[] memory candidates, string memory userId, string memory salt) public {
        require(candidates.length > 0, "No candidates provided");
        bytes32 voteId = keccak256(abi.encodePacked(userId, salt));  // <== vuln
        Vote storage v = votes[voteId];
        v.exists = true;
        for(uint i = 0; i < candidates.length; i++) {
            v.candidateHashes.push(keccak256(abi.encodePacked(candidates[i], salt)));
        }
    }

    // Casts a vote for a candidate
    function castVote(bytes32 voteId,string memory userId, string memory candidate, string memory salt) public {
        require(votes[voteId].exists, "Vote does not exist");
        require(!votes[voteId].voted[userId], "Already voted");

        bytes32 candidateHash = keccak256(abi.encodePacked(candidate, salt));  // <== vuln
        require(isValidCandidate(voteId, candidateHash), "Invalid candidate");

        votes[voteId].voted[userId] = true;
        votes[voteId].results[candidateHash]++;
    }

    // Checks if a given candidate is valid for a vote
    function isValidCandidate(bytes32 voteId, bytes32 candidateHash) private view returns (bool) {
        for(uint i = 0; i < votes[voteId].candidateHashes.length; i++) {
            if(votes[voteId].candidateHashes[i] == candidateHash) {
                return true;
            }
        }
        return false;
    }

    // Returns the total votes for each candidate in a vote
    function getResults(bytes32 voteId) public view returns (uint256[] memory) {
        require(votes[voteId].exists, "Vote does not exist");
        uint256[] memory results = new uint256[](votes[voteId].candidateHashes.length);
        for (uint256 i = 0; i < votes[voteId].candidateHashes.length; i++) {
            results[i] = votes[voteId].results[votes[voteId].candidateHashes[i]];
        }
        return results;
    }

    // Checks if a specific address has already voted in a vote
    function hasVoted(bytes32 voteId, address voter) public view returns (bool) {
        require(votes[voteId].exists, "Vote does not exist");
        return votes[voteId].voted[voter];
    }

    // Returns the number of votes for a specific candidate in a vote
    function getVotesForCandidate(bytes32 voteId, string memory candidate, string memory salt) public view returns (uint256) {
        require(votes[voteId].exists, "Vote does not exist");
        bytes32 candidateHash = keccak256(abi.encodePacked(candidate, salt));  // <== vuln
        require(isValidCandidate(voteId, candidateHash), "Invalid candidate");
        return votes[voteId].results[candidateHash];
    }
}
