pragma solidity ^0.4.15;


/*mimble_wimble_solidity
the main idea is to develop an ultra efficient way to launch a plasma channel
if the dictator follows the mimblewimble protocol, and all the validators validate, the transaction
throughput could be quite high (use bulletproofs as well in this construction).
using a different cryptocurrency on this payment channel would provide a real-time gauge of the channel's
use, popularity, and liquidity properties.
*/
contract MimbleWimble {
    //WHAT DO EVENTS EVEN CONSIST OF????
    //event sendTransaction()
    //event bulletproof()
    //event verifyecc()

    uint constant public MAX_OWNER_COUNT = 50;

    //A MimbleWimble transaction includes the following:
    //1) a set of  inputs that reference and spend a set of previous outputs
    //2) a set of new outputs that include:
    //--a value and a binding factor (which is a just a new private key) multiplied on a curve and summed to be
    //r*G + v*H.
    //--a range proof that shows that v is non-negative.
    //3)an explicit transaction fee, in clear
    //4)a signature, computed by taking the excess binding value (the sum of all outputs plus the fee, minus the inputs)
    //and using it as a private key

    //maybe even think of having each person validate their own transactions, and then they send a proof that their transaction
    //is valid or something along those lines...could have miners too but blockchain computation seems like such a trivial task in this context
    struct Transaction {
        uint[] inputs, //and previous outputs or verify that these inputs spend a set of previous outputs
        uint[] outputs,
        uint transactionFee, //this is the fee that the dictator takes
        uint signature
    }

    //consider making a struct for the elliptic curve signature

    modifier checkInputs() {
        //check the inputs and verify that they spend the previous outputs
    }

    modifier check_value_and_binding_factor() {
        //check the value and binding factor on outputs
    }

    modifier valid_utxo() {
        // there has to be a modifier to check the inputs relative to the outputs
    }

    function verify_Transaction() {
        //some formal process to verify the process
    }




}

//Open-Question(s):
/*
Privacy isn't really guaranteed unless we do some kind of mixing with the incoming and outgoing
transactions (like Coinjoin). Or we could generate some master public key and use it to generate stealth addresses
for people exiting (but I would need to verify that this would work in the context of stealth addresses)

*/
