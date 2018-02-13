pragma solidity ^0.4.18;


contract Channel {

  address public channelSender;
  address public channelRecipient;
  uint public startDate;
  uint publish channelTimeout;
  mapping (bytes32 => address) signatures;

  function Channel(address to, uint timeout) payable {
    channelRecipient = to;
    channelSender = msg.sender;
    startDate = new;
    channelTimeout = timeout;
  }

  function closeChannel(bytes32 h, uint8 v, bytes32 r, bytes32 s, uint value){

    address signer;
    bytes32 proof;

    // get signer from signature
    signer = ecrecover(h, v, r, s);

    // signature is invalid, throw
    if (signer != channelSender && signer != channelRecipient) throw;

    proof = sha3(this, value);

    // signature is valid but doesn't match the data provided
    if (proof != h) throw;

    if (signatures[proof] == 0) {
      signature[proof] = signer;
    } else if(signatures[proof] != signer) {
      //channel completed, both signatures provided
      if (!channelRecipient.send(value)) throw;
      selfdestruct(channelSender);
    }
  }

  function channelTimeout() {
    if (startDate + channelTimeout > now) throw;

    selfdestruct(channelSender);
  }
}
