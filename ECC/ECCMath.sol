solidity ^0.4.18;


//this is borrowed from Andreas Olofsson's github
//https://github.com/androlo/standard-contracts/blob/master/contracts/src/crypto/ECCMath.sol

library ECCMath {
     //the moduler inverse of a using euclid
     //this allows us to do division over a finite field in a sense (taking the inverse)
     function invmod(uint a, uint p) internal constant returns (uint) {
          require(!(a == 0 || a ==p || p == 0));
          if (a > p) {
               a = a % p;
          }

          uint t1;
          uint t2 = 1;
          uint r1 = p;
          uint r2 = a;
          uint q;
          while (r2 != 0) {
               q = r1/r2;
               (t1, t2, r1, r2) = (t2, t1 - int(q)*t2, r2, r1-q*r2);
          }
          if (t1 < 0) {
               return (p - uint(-t1));
          }
          return uint(t1);
     }

     //modular exponention like
     //b^(e%m)
     function expmod(uint b, uint e, uint m) internal constant returns (uint r) {
          if (b==0) {
               return 0;
          }
          if (e == 0) {
               return 1;
          }
          require(m!=0);
          r = 1;
          uint bit = 2 ** 255;
          assembly {
               loop:
                    jumpi(end, iszero(bit))
                     r := mulmod(mulmod(r, r, m), exp(b, iszero(iszero(and(e, bit)))), m)
                     r := mulmod(mulmod(r, r, m), exp(b, iszero(iszero(and(e, div(bit, 2))))), m)
                     r := mulmod(mulmod(r, r, m), exp(b, iszero(iszero(and(e, div(bit, 4))))), m)
                     r := mulmod(mulmod(r, r, m), exp(b, iszero(iszero(and(e, div(bit, 8))))), m)
                     bit := div(bit, 16)
                     jump(loop)
               end:
          }
     }

     //converts a point (Px, Py, Pz) expressed in Jacobian coordinates to (Px', Py', 1)
     //thereby mutating P
     //the parameter is the point P
     //zInv is the modular inverse of 'Pz'
     //z2Inc is the square of zInv
     //prime is the prime modulus
     // return (Px', Py', 1)
     function toZ1(uint[3] memory P, uint zInv, uint z2Inv, uint prime) interal constant
     {
          P[0] = mulmod(P[0], z2Inv, prime);
          P[1] = mulmod(P[1], mulmod(zInv, z2Inv, prime), prime);
          P[2] = 1;
     }

     //overloaded function but they take different types so this is ok
     function toZ1(uint[3] PJ, uint prime) internal constant {
          uint zInv = invmod(PJ[2], prime);
          uint zInv2 = mulmod(zInv, zInv, prime);
          PJ[0] = mulmod(PJ[0], zInv2, prime);
          PJ[1] = mulmod(PJ[1], mulmod(zInv, zInv2, prime), prime);
          PJ[2] = 1;
     }
}
