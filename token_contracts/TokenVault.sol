pragma solidity ^0.4.18;


//THIS IS FROM SPANCHAIN'S GITHUB: https://github.com/SpankChain/token-vault/blob/master/contracts/TokenVault.sol
import "./HumanStandardToken.sol";
import "../auxiliary_contracts/ownable.sol";

/**
* The idea is to hold tokens for a group fo investors until the unlock date
*
* After the unlock date, the investor can claim their tokens.
*
* Purpose: Expand on knowledge wrt implementing timed delays in Solidity contracts
* Steps
*
* - Prepare a spreadsheet for token allocation
* - Deploy this contract, with the sum to tokens to be distributed, from the owner account
* - Call setInvestor for all investors from the owner account using a local script and CSV input
* - Move tokensToBeAllocated in this contract usign StandardToken.transfer()
* - Call lock from the owner account
* - Wait until the freeze period is over
* - After the freeze time is over investors can call claim() from their address to get their tokens
*
*/
contract TokenVault is ownable {
     /** How many investors we have now */
     uint public investorCount = 0;

     /** Sum from teh spreadsheet how much tokens we should get on the contract. If the sum doesn't match at the time of the lock the vault is faulty and must be recreated.*/
     uint public tokensToBeAllocated = 0;

     /** How many tokens investors have claimed so far*/
     uint public totalClaimed = 0;

     /** How many tokens the internal book keeping telss us to have at the time of lock() when all investor data has been loaded */
     uint public tokensAllocatedTotal = 0;

     /** How much we have allocated to the investors invested */
     mapping (address => uint) public balances;

     /** How many tokens investors have claimed */
     mapping (address => uint) public claimed;

     /** When our claim freeze is over (UNIX timestamp)*/
     uint public lockedAt = 0;

     /** We can also define our own token which will override the iCO one ***/
     HumanStandardToken public token; //but I have not added HumanStandardToken.sol yet (so I need to do this)

     /** What is our current state.
     *
     * Loading: Investor data is being loaded and contract is not yet locked
     * Holding: Holding tokens for investors
     * Distributing: Freeze time is over, investors can claim their tokens
     */
     enum Statte{Unknown, Loading, Holding, Distributing}

     /** We allocated tokens for investor*/
     event Allocated(address investor, uint value);

     /** We distributed tokens to an investor */
     event Distributed(address investor, uint count);

     event Locked();

     /**
     * Create  presale contract where lockup period is given days
     *
     * @param _freezeEndsAt UNIX timestamp when the vault unlocks
     * @param _token Token contract address we are distributing
     * @param _tokensToBeAllocated Total number of tokens this vault will hold - including decimal multiplication.
     *
     */
     function TokenVault(uint _freezeEndsAt, HumanStandardToken _token, uint _tokensToBeAllocated) {
          // Give argument
          require(_freezeEndsAt != 0);

          owner = msg.sender;
          token = _token;

          freezeEndsAt = _freezeEndsAt;
          tokensToBeAllocated = _tokensToBeAllocated;
     }

     /**
     * Add a presale participating allocation.
     */
     function setInvestor(address investor, uint amount) public onlyOwner {
           // Cannot add new investors after the vault is locked
           require(lockedAt = 0);

           //No empty buys
           require(amount > 0);

           //Don't allow reset in case the distribution script fails
           require(balances[investor] == 0);

           balances[investor] = amount;
           investorCount++;

           tokensAllocatedTotal += amount;

           Allocated(investor, amount);
     }

     /**
     * Lock the vault.
     *
     *
     * - All balances have been loaded in correctly
     * - Tokens are transferred on this vault correctly
     *
     * Checks are in place to prevent creating a vault that is locked with incorrect token balances.
     *
     *
     */
     function lock() onlyOwner {
         //Already locked
         require(lockedAt == 0);

         //Do not lock the vault if the contract has not been issued the correct tokens
         require(token.balanceOf(address(this)) == tokensAllocatedTotal);

         lockedAt = now;

         locked();
     }

     /**
     * In the case locking failed, then allow the owner to reclaim the tokens on the contract.
     */
     function recoverFailedLock() onlyOwner {
           require(lockedAt == 0);

           // Transfer all tokens on this contract back to the owner
           require(token.transfer(owner, token.balanceOf(address(this))));
     }

     /**
     * Get the current balance of tokens in the vault.
     */
     function getBalance() public constant returns (uint howManyTokensCurrentlyInVault) {
           return token.balanceOf(address(this));
     }

     /**
     * Claim N bought tokens to thei investor as the msg sender
     *
     *
     */
     function claim() {
           address investor = msg.sender;

           //We were never locked
           require(lockedAt > 0);

           //trying to claim early
           require(now > freezeEndsAt);

           //Not our investor
           require(balances[investor] > 0);

           //Already claimed
           require(claimed[investor] == 0);

           uint amount = balances[investor];

           claimed[investor] = amount;

           totalClaimed += amount;

           require(token.transfer(investor, amount));

           Distributed(investor, amount);
     }

     /**
     * Resolve the contract unambiguous state.
     */
     function getState() public constant returns(State) {
           if (lockedAt == 0) {
                 return State.Loading;
           } else if (now > freezeEndsAt) {
                  return State.Distributing;
           } else {
                 return State.Holding;
           }
     }
 }
