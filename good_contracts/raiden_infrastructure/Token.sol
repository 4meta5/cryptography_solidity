pragma solidity ^0.4.11;

interface Token {
      // return total amount of tokens
      function totalSupply() public constant returns (uint256 supply);


      //The address from which the balance will be retrieved
      //return the balance
      function balanceOf(address _owner) public constant returns (uint256 balance);

      //send _vlue token to _to from msg.sender
      //_to is the address of the recipient
      // _value is the amount of token to be transferred
      // Whether the transfer was successful or not
      function transfer(address _to, uint256 _value) public returns (bool success);

      //send _value token to _to from _from on the condition that it is approved by _from
      // _from is the address of the sender
      // _to is the address of the recipient
      // _value is the amount of token to be transferred
      // it will return whether the transfer was successful or not (and we need to act on that!)
      function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);


      //msg.sender approved _spender to spend _value tokens
      //_spender is the address of the account able to transfer the tokens
      //_value is the amount of wei to be approved for transfer
      //it returns whether the approval was successful or not
      function approve(address _spender, uint256 _value) public returns (bool success);

      //_owner the address of the account owning tokens
      //_spender is the address of the account able to transfer the tokens
      // it returns the remaining tokens allowed to be spent
      function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

      event Transfer(address indexed _from, address indexed _to, uint256 _value);
      event Approval(address indexed _owner, address indexed _sender, uint256 _value); 
}
