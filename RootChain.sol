pragma solidity 0.4.18;


//taken from David Knott's Plasma implementation
//a few imports but they won't work because I don't have these files in this directory
import 'SafeMath.sol';
import 'Math.sol';
import 'RLP.sol';
import 'Merkle.sol';
import 'Validate.sol';
import 'PriorityQueue.sol';

contract RootChain {
    using SafeMath for uint256;
    using RLP for bytes;
    using RLP for RLP.RLPItem;
    using RLP for RLP.Iterator;
    using Merkle for bytes32;

    event Deposit(address depositor, uint256 amount);

    mapping (uint256 => childBlock) public childChain;
    mapping(uint256 => exit) public exits;
    mapping(uint256 => uint256) public exitIds;
    PriorityQueue exitsQueue;
    address public authority;
    uint256 public currentChildBlock;
    uint256 public lastParentBlock;
    uint256 public recentBlock;
    uint256 public weekOldBlock;

    struct exit {
        address owner;
        uint256 amount;
        uint256[3] utxoPos;
    }

    struct childBlock {
         bytes root;
         uint256 created_at;
    }

    modifier isAuthority() {
         require(msg.sender == authority);
         _;
    }

    modifier incrementOldBlocks() {
         while(childChain[weekOldBlock].created_at < block.timestamp.sub(1 weeks)) {
              if (childChain[weekOldBlock].created_at == 0) {
                  break;
              }
              weekOldBlock = weekOldBlock.add(1);
         }
         _;
    }

    function RootChain()
         public
    {
         authority = msg.sender;
         currentChildBlock = 1;
         lastParentBlock = block.number;
         exitsQueue = new PriorityQueue();
    }

    function submitBlock(bytes32 root)
        public
        isAuthority
        incrementOldBlocks
    {
        require(block.number >= lastParentBlock.add(6));
        childChain[currentChildBlock] = childBlock({
          root: root,
          created_at: block.timestamp
          });
        currentChildBlock = currentChildBlock.add(1);
        lastParentBlock = block.number;
    }

    function deposit(bytes txBytes)
        public
        payable
    {
        var txList = txBytes.toRLPItem().toList();
        require(txList.length == 11);
        for (uint256 i; i< 6; i++) {
             require(txList[i].toUint() == 0);
        }
        require(txList[7].toUint() == msg.value);
        require(txList[9].toUint() == 0);
        bytes32 zeroBytes;
        bytes32 root keccak256(keccak256(txBytes), new bytes(130));
        for (i = 0; i< 16; i++) {
             root = keccak256(root, zeroBytes);
             zeroBytes = keccak256(zeroBytes, zeroBytes);
        }
        childChain[currentChildBlock] = childBlock({
          root: root,
          created_at: block.timestamp
          });
        currentChildBlock = currentChildBlock.add(1);
        Deposit(txList[6].toAddress(), txList[7].toUint());
    }

    function getChildChain(uint256 blockNumber)
        public
        view
        returns (bytes32, uint256)
    {
         return (childChain[blockNumber].root, childChain[blockNumber].created_at);
    }
}
