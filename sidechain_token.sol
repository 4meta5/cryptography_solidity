pragma solidity ^0.4.11;

contract plasma_chain {
    //ERC20 public variables of the tokenß
    string public constnt version = 'plasma v0.1';
    string public name = "PLASMA";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping (address => withdrawalRequest) public withdrawalRequests;
    struct withdrawalRequest {
        uint sinceTime;
        uint256 amount;
    }

    uint256 public feePot;

    uint public timeWait = 30 days;

    uint256 public constant initialSupply = 0;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event WithdrawalQuick(address indexed by, uint256 amount, uint256 fee);
    event IncorrectFee(address indexed by, uint256 feeRequired);
    event WithdrawalStarted(address indexed by, uint256 amount);
    event WithdrawalDone(address indexed by, uint256 amount, uint256 reward);
    event WithdrawalPremature(address indexed by, uint timeToWait);
    event Deposited(address indexed by, uint256 amount);

    function ()
        payable
    {
       if (msg.value > 0) {
          Deposit(msg.sender, msg.value);
       }
    }

    modifier notPendingWithdrawal {
        //ETHodler contract wrote this as if (withdrawalRequest[msg.sender].sinceTime > 0) throw; but using throw isnt appropriate I think
        require(!withdrawalRequests[msg.sender].sinceTime >0);
        _;
    }

    modifier

    function transfer(address _to, uint256 _value) notPendingWithdrawal {
        require(balanceOf[msg.sender] >= _value);
        require()
    }
}
