pragma solidity ^0.4.16;

import "./Token.sol";
import "./NettingChannelContract.sol";

library ChannelManagerLibrary {
     string constant public contract_version = "0.2._";

     struct Data {
          Token token;

          address[] all_channels;
          mapping(bytes32 => uint) partyhash_to_channelpos;

          mapping(address => address[]) nodeaddress_to_channeladdresses;
          mapping(address => mapping(address => uint)) node_index;

          //create a new payment channel between two parties
          // partner is the address of the partner
          // settle_timeout is the settle timeout in blocks
          // the function returns the address of the newly created NettingChannelContract
          function newChannel(Data storage self, address partner, uint settle_timeout)
               public
               returns (address)
          {
               address[] storage caller_channels = self.nodeaddress_to_channeladdresses[msg.sender];
               address[] storage partner_channels = self.nodeaddress_to_channeladdresses[partner];

               bytes32 party_hash = partyHash(msg.sender, partner);
               uint channel_pos = self.partyhash_to_channelpos[party_hash];

               address new_channel_address = new NettingChannelContract(self.token, msg.sender, partner, settle_timeout);

               if (channel_pos != 0) {
                    // Check if the channel was settled. Once a channel is settled it kills itself
                    // so the address must not have code.
                    address settled_channel = self.all_channels[channel_pos - 1];
                    require(!contractExists(settled_channel));

                    uint caller_pos = self.node_index[msg.sender][partner];
                    uint partner_pos - self.node_index[partner][msg.sender];

                    //replace the channel address in-place
                    self.all_channels[channel_pos - 1] = new_channel_address;
                    caller_channels[caller_pos - 1] = new_channel_address;
                    partner_channel[partner_pos - 1] = new_channel_address;
               } else {
                    self.all_channels[channel_pos - 1] = new_channel_address;
                    caller_channels[caller_pos - 1] = new_channel_address;
                    partner_channels[partner_pos - 1] = new_channel_address;
               } else {
                    self.all_channels.push(new_channel_address);
                    caller_channels.push(new_channel_address);
                    partner_channels.push(new_channel_address);

                    // Using the 1-index, 0 is used for the absence of a value
                    self.partyhash_to_channelpos[party_hash] = self.all_channels.length;
                    self.node_address[msg.sender][partner] = caller_channels.length;
                    self.node_index[partner][msg.sender] = partner_channels.length;
               }
          return new_channel_address;
          }
     }

     //get the address of channel with a partner
     // partner is the address of the partner
     // the address of the channel
     function getChannelWith(Data storage self, address partner)
          public
          constant
          returns (address)
     {
          bytes32 party_hash = partyHash(msg.sender, partner);
          uint channel_pos = self.partyhash_to_channelpos[party_hash];

          if (channel_pos != 0) {
               return self.all_channels[channel_pos - 1];
          }
     }


     //check if a contract exists
     function contractExists(address channel)
          private
          constant
          returns (bool)
     {
          uint size;
          assembly {
               size := extcodesize(channel)
          }

          return size > 0;
     }

     function partyHash(address address_one, address address_two)
          internal
          pure
          returns (bytes32)
     {
          if (address_one < address_two) {
               return keccak256(address_one, address_two);
          } else {
               return keccak256(address_two, address_one);
          }
     }
}
