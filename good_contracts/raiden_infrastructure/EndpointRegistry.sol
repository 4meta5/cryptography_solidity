pragma solidity ^0.4.18;


contract Endpoint Registry {
     string constant public contract_version = "0.2_";

     event AddressRegistered(address indexed eth_address, string socket);

     //Mapping of Ethereum Addresses => SocketEndpoints
     mapping (address => string) address_to_socket;
     // Mapping of SocketEndpoints => Ethereum Addresses
     mapping (string => address) socket_to_address;
     // list of all the Registered Addresses, still not used.
     address[] eth_addresses;

     modifier noEmptyString(string str)
     {
          require(equals(str, "") != true);
          _;
     }

     //this function registers the Ethereum address to the endpoint socket
     //registers the Ethereum address to the endpoint socket
     //param is a string of socket in the form "127.0.0.1:40001"
     function registerEndpoint(string socket )
          public
          noEmptyString(socket)
    {
         string storage old_socket = address_to_socket[msg.sender];

         //Compare if the new socket matches the old one, if it does just return
         if (equals(old_socket, socket)) {
              return;
         }

         //Put the ethereum address 0 in front of the old_socket, old_socket:0x0
         socket_to_address[old_socket] = address(0);
         address_to_socket[msg.sender] = socket;
         socket_to_address[socket] = msg.sender;
         AddressRegistered(msg.sender, socket);
    }

    //this function finds the socket if given an Ethereum address
    //finds the socket if given an Ethereum address
    //an eth_address which is a 20 byte Ethereum address
    //returns a socket which the current Ethereum Address is using
    function findEndpointByAddress(address eth_address) public constant returns (string socket)
    {
         return address_to_socket[eth_address];
    }

    function equals(string a, string b) internal pure returns (bool result)
    {
         if (keccak256(a) == keccak256(b)) {
              return true;
         }

         return false;
    }
}
