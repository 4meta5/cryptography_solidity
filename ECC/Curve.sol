pragma solidity ^0.4.18;

//this is an interface for elliptic curves that facilitates the computation necessary
//for certain cryptographic primitives


//the original author is Andreas Oloffson https://github.com/androlo/standard-contracts/blob/master/contracts/src/crypto/Curve.sol
//I may add to this depending on the cryptographic primitives that I use in the future because this seems convenient
contract Curve {

      /// @dev Check whether the input point is on the curve
      //// SEC 1: 3.2.3.1
      /// the param P is a point
      /// returns True if the point on the cuurve and false otherwise
      function onCurve(uint[2] P) constant returns (bool);

      /// @dev Check if the given point is a valid public key
      /// SEC 1: 3.2.3.1
      /// the point P is a param
      /// @return True if the point is on the curve
      function isPubKey(uint[2] P) constant returns (bool);

      /// @dev
      /// SEC 1: 4.1.4
      /// @param h is the hash of the message
      /// @param rs is the signature (r, s)
      /// @param Q is the public key to validate against
      /// @return True if the point is on the curve
      function validateSignature(bytes32 h, uint[2] rs, uint[2] Q) constant returns (bool);

      /// @dev compress a point 'P = (Px, Py)' on the curve, giving 'C(P) = (yBit, Px)'
      /// SEC 1: 2.3.3 - but only the curve-dependent code.
      /// @param yBit the compressed y-coordinate (one bit)
      /// @param Px the x-coordinate
      /// @param True if the point is on the curve.
      function decompress(uint8 yBit, uint Px) constant returns (uint[2] Q);


}
