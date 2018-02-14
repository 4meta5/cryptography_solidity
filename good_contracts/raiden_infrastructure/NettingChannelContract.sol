pragma solidity ^0.4.11;

import "./NettingChannelLibrary.sol";

contract NettingChannelLibrary {
     string constant public contract_version = "0.2._";

     using NettingChannelLibrary for NettingChannelLibrary.Data
     NettingChannelLibrary.Data public data;

     event  ChannelNewBalance(address token_address, address participant, uint balance);
     event ChannelClosed(address closing_address);
     event TransferUpdated(address node_address);
     event ChannelSettled();
     event ChannelSecretRevealed(bytes32 secret, address receiver_address);

     modifier settleTimeoutValid(uint t) {
          require(t >= 6 && t <= 2700000);
          _;
     }

     function NettingChannelContract(
       address token_address,
       address participant1,
       address participant2,
       uint timeout
       )
       public
       settleTimeoutValid(timeout)
    {
        require(participant1 != participant2);
        data.participants[0].node_address = participant1;
        data.participants[1].node_address = participant2;
        data.participant_index[participant1] = 1;
        data.participant_index[participant2] = 2;

        data.token = Token(token_address);
        data.settle_timeout = timeout;
        data.opened = block.number;
    }

    //caller makes a deposit into their channel balance
    // param is the amount the caller wants to deposit
    // returns true if the deposit is successful
    function deposit(uint256 amount)
         public
         returns (bool)
    {
         bool success;
         uint256 balance;

         //see function deposit(Data storage self, uint256 amount) in library
         (success, balance) = data.deposit(amount);

         if (success == true) {
            ChannelNewbalance(data.token, msg.sender, balance);
         }

         return success;
    }

    //get the address and balance of both partners in the channel
    //and therefpore return the address and balance pairs
    function addressAndBalance()
         public
         constant
         returns (address participant1, uint balance1, address participant2, uint balance2)
    {
         NettingChannelLibrary.Participant storage node1 = data.participant[0];
         NettingChannelLibrary.Participant storage node2 = data.participant[1];

         participant1 = node1.node_address;
         balance1 = node1.balance;
         participant2 = node2.node_address;
         balance2 = node2.balance;
    }

    //close the channel; can only be called by a participant in the channel
    function close(
      uint64 nonce,
      uint256 transferred_amount,
      bytes32 locksroot,
      bytes32 extra_hash,
      bytes32 signature
      )
      public
    {
         data.close(nonce, transferred_amount, locksroot, extra_hash, signature);
         ChannelClosed(msg.sender);
    }

    function updateTransfer(uint64 nonce, uint256 transferred_amount, bytes32 locksroot, bytes32 extra_hash, bytes signature)
         public
    {
         data.updateTransfer(nonce, transferred_amount, locksroot, extra_hash, signature);
         TransferUpdated(msg.sender);
    }

    //unlock a locked transfer
    //locked_encoded is the locked transfer to be unlocked
    // merkle_proof is the merkle proof for the locked transfer
    // secret The secret to unlock the locked transfer
    function withdraw(bytes locked_encoded, bytes merkle_proof, bytes32 secret) public {
         //throws if sender isn't a participant
         data.withdraw(locked_encoded, merkle_proof, secret);
         ChannelSecretRevealed(secret, msg.sender);
    }

    //this sett;es the transfers and balances of the channel and pays out
    //to each participant. Can only be called after the channel is closed and only
    // after the number of blocks in the settlement timeout have passed
    function settle() public {
         data.settle();
         ChannelSettled();
    }

    // retusn the number of blocks until the settlement timeout
    function settleTimeout() public constant returns (uint) {
         return data.settle_timeout;
    }

    // returns the address of the token
    // and the address of the token
    function tokenAddress() public constant returns(address) {
         return data.token;
    }

    //returns the block number for when the channel was opened
    // the block number for when the channel was opened
    function oepned() public constant returns (uint) {
         return data.closed;
    }

    //returns the address of the closing participants
    function closingAddress() public constant returns(address) {
         return data.closing_address;
    }

    function() public { revert();}
}
