pragma solidity ^0.4.18;

import "./Curve.sol";
import "./Secp256k1";

//this contract is a Secp256k1 contract that implements the Curve interface

//originally written by Andreas Oloffson https://github.com/androlo/standard-contracts/blob/master/contracts/src/crypto/Secp256k1Curve.sol
//extend this curve interface or a similar one to the other protocols in SEC 1
contract Secp256k1Curve is Curve {
    function onCurve(uint[2] P) constant returns (bool) {
         return Secp256k1.onCurve(P);
    }

    function isPubKey(uint[2] P) constant returns (bool) {
         return Secp256k1.isPubKey(P);
    }

    function validateSignature(bytes32 h, uint[2] rs, uint[2] Q) constant returns (bool) {
         return Secp256k1.validateSignature(h, rs, Q);
    }

    function compress(uint[2] P) constant returns (uint8 yBit, uint x) {
         return Secp256k1.compress(P);
    }

    function decompress(uint8 yBit, uint Px) constant returns (uint[2]) {
         return Secp256k1.decompress(yBit, Px);
    }
}
