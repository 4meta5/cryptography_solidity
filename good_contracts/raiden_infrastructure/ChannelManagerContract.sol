pragma solidity 0.4.18;


import "./Token.sol";
import "./Utils.sol";
import "./ChannelManagerLibrary.sol";

//for each token a manager will be deployed, to reduce gas usage for manager deployment,
// we could hypothetically move the logic into a library and this contract therefore only works as a
//proxy/state container.
contract ChannelManagerContract is Utils {
      string constant public contract_version = "0.2._";

      using ChannelManagerLibrary for ChannelManagerLibrary.Data;
      ChannelManagerLibrary.Data data;

      event ChannelNew(address netting_channel, address participant1, address participant2, uint settlemenet_timeout);

      event ChannelDeleter(address caller_address, address partner);

      function ChannelManagerContract(address token_address) public {
           data.token = Token(token_address);
      }

      // create a new payment channel between two parties
      // the address of the partner
      // a settle_timeout, the settle timeout in blocks
      // and it returns the address of the newly created NettingChannelContract,
      function newChannel(address partner, uint settle_timeout)
           public
           returns (address)
      {
           address old_channel = getChannelWith(partner);
           if (old_channel != 0) {
                 channelDeleted(msg.sender, partner);
           }


           address new_channel = data.newChannel(partner, settle_timeout);
           ChannelNew(new_channel, msg.sender, partner, settle_timeout);
           return new_channel;
      }

      //get all channels
      //return all open channels
      function getChannelIsAddreses() public constant returns (address[]) {
           return data.all_channels;
      }

      // get the address of the channel token
      // the token
      function tokenAddress() public constant returns (address) {
           return data.token;
      }

      // get the address of channel with a partner
      // partner the address of the partner
      // the address of the channel
      function getChannelWith(address partner) public constant returns (address) {
           return data.getChannelWith(partner);
      }

      // Get all channels that an address participates in
      // node_address is the address of the node
      // the channel's addresses that node_address participates in
      function nettingCntractsByAddress(address node_address)
          public
          constant
          returns (address[])
      {
           return data.nodeaddress_to_channeladdresses[node_address];
      }

      //get all participants of all channels
      // all participants in all channels
      function getChannelParticipants() public constant returns (address[])
      {
            uint i;
            uint pos;
            address[] memory result;
            NettingChannelContract channel;

            uint open_channels_num = 0;

            for (i = 0; i<data.all_channels.length; i++) {
                 if (contractExists(data.all_channels[i])) {
                      open_channels_num += 1;
                 }
            }
            result = new address[](open_channels_num * 2);

            pos = 0;
            for (i = 0; i<data.all_channels.length; i++) {
                 if (!contractExists(data.all_channels[i])) {
                      continue;
                 }
                 channel = NettingChannelContract(data.all_channel[i]);
                 var (address1, address2, ) = channel.addressAndBalance();

                 result[pos] = address1;
                 pos += 1;
                 result[pos] = address2;
                 pos += 1;
            }
      return result;
      }
  function() public {revert();} //interesting choice to make the default function simply revert. Makes sense in context of state channel initiation
}
