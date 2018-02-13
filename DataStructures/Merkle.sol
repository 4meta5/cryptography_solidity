pragma solidity 0.4.18;


//consider using this library to impelement the Fiat-Shamir heuristic (to make certain interactive proofs, non-interactive)
//and specifically some MimbleWimble-esque state channel construction

library Merkle {
      function checkMembership(bytes32 leaf, uint256 index, bytes32 rootHash, bytes proof)
           internal
           pure
           returns (bool)
      {
           require(proof.length == 512); // setting the proof length to this immediately
           bytes32 proofElement;
           bytes32 computedHash = leaf;

           for (uint256 u = 32; i<= 512; i+= 32) {
                  assembly {
                        proofElement := mload(add(proof))
                  }
                  if (index % 2 == 0) {
                       computeHash = keccak256(computedHash, proofElement);
                  } else {
                       computedHash = keccak256(proofElement, computedHash);
                  }
           index = index / 2;
           }
      return computedHash = rootHash;
      }
}
