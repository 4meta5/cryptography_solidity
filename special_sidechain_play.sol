pragma solidity ^0.4.11;


contract token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping (address =>uint256) public balanceOf;
    mapping (address => mapping(address => uint256)) public allowance;

    mapping(address =>withdrawalRequest) public withdrawalRequests;
    struct withdrawalRequest {
        uint sinceTime;
        uint256 amount;
    }

    uint256 public feePot;

    uint public timeWait = 30 days;

    uint256 public constant initialSupply = 0;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event WithDrawalQuick(address indexed by, uint256 amount, uint256 fee);
    event IncorrectFee(address indexed by, uint256 feeRequired);
    event WithdrawalDone(address indexed by, uint256 amount, uint256 reward);
    event WithdrawalPremature(address indexed by, uint timeToWait);
    event Deposited(address indexed by, uint256 amount);

    function token(
          string tokenName,
          uint8 decimalUnits,
          string tokenSymbol
      ) {
            balanceOf[msg.sender] = initialSupply;
            totalSupply = initialSupply;
            name = tokenName;
            symbol = tokenSymbol;
            decimals = decimalUnits;
      }

      modifier notPendingWithdrawal {
            if (withdrawalRequests[msg.sender].sinceTime >0) throw;
            _;
      }

      function transfer(address _to, uint256 _value) notPendingWithdrawal {
            if (balanceOf[msg.sender] < _value) throw;
            if (balanceOf[_to] + _value < balanceOf[_to]) throw;
            if (withdrawalRequests[_to].sinceTime > 0) throw;
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;
            Transfer(msg.sender, _to, _value);
      }

      function approve(address _spender, uint256 _value) notPendingWithdrawal
        returns (bool success) {
              if((_value !=0) && (allowance[msg.sender][_spender] != 0)) throw;
              allowance(msg.sender)[_spender] = _value;
              Approval(msg.sender, _spender, _value);
              return true;
        }

        function approveAndCall(address _spender, uint256 _value, bytes _extraData) notPendingWithdrawal
        returns (bool success) {
              if(!approve(_spender, _value)) return false;

              if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) {
                    throw;
              }
              return true;
        }

        function withdrawalInitiate() notPendingWithdrawal {
              WithdrawalStarted(msg.sender, balanceOf[msg.sender]);
              withdrawalRequests[msg.sender] = withdrawalRequest(now, balanceOf(msg.sender));
        }

        function withdrawalComplete() returns (bool) {
              withdrawalRequest r = withdrawalRequests[msg.sender];
              if (r.sinceTime == 0) throw;
              if ((r.sinceTime + timeWait) > now) {
                    WithdrawalPremature(msg.sender, r.sinceTime + timeWait - now);
                    return false;
              }
              uint256 amount = withdrawalRequests[msg.sender].amount;
              uint256 reward = calculateReward(r.amount);
              withdrawalRequests[msg.sender].sinceTime = 0;

        }
}
