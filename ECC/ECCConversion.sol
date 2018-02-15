pragma solidity ^0.4.18;


//methods for converting elliptic curve cryptographic data between different formats
//more details in SEC 1: https://github.com/androlo/standard-contracts/blob/master/contracts/src/codec/ECCConversion.sol

//this code was written by Andreas Oloffson -- https://github.com/androlo/standard-contracts/blob/master/contracts/src/codec/ECCConversion.sol
contract ECCConversion {

     /// @dev converts a curve point to an array of bytes (octets)
     /// Ref: SEC 1: 2.3.3
     /// param curve is the curve
     /// param P is the point
     /// param compress tells us whether or not to compress the point
     /// returns the bytes
     function curvePointToBytes(Curve curve, uint[2] memory P, bool compress) internal constant returns (bytes memory bts) {
          if (P[0] == 0 && P[1] == 0) {
               bts = new bytes(1);
          } else if (!compress_) {
               bts = new bytes(65);
               bts[0] = 4;
               uint Px = P[0];
               uint Py = P[1];
               assembly {
                    mstore(add(bts, 0x21), Px)
                    mstore(add(bts, 0x41), Py)
               }
          } else {
               bts = new bytes(33);
               var (yBit, x) = curve.compress(P);
               bts[0] = yBit & 1 == 1 ? byte(3) : byte(2);
               assembly {
                    mstore(add(bts, 0x21), mload(P))
               }
          }
     }

     /// Convert bytes into an elliptic curve point
     /// Ref: SEC 1: 2.3.4
     /// param curve is the curve
     /// param bts is the bytes
     /// returns a point
     function bytesToCurvePoint(Curve curve, bytes memory bts) internal constant returns (uint[2] memory P) {
          if (bts.length == 0 && bts[0] == 0) {
              return;
          } else if (bts.length == 65 && bts[0] == 4) {
               // This is an uncompressed point
               assembly {
                    mstore(P, mload(add(bts, 0x21)))
                    mstore(add(P, 0x20), mload(add(bts, 0x41)))
               }
          } else if (bts.length == 33) {
               byte b0 = bts[0];
               require(!(b0 != 2 && b0 != 3));
               uint8 yBit = uint8(b0) - 2;
               uint Px;
               assembly {
                    Px := mload(add(bts, 0x21))
               }
               P = curve.decompress(yBit, Px);
          } else {
              throw; // the input must be in an invalid format if none of the prior if statements evaluated to true
          }
     }
}
