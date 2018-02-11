pragma solidity ^0.4.16;


contract Ballot {
    struct Voter {
         uint weight;
         bool voted;
         address delegate;
         uint vote;
    }

    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    function Ballot(bytes32[] proposalNames) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint i = 0; i<proposalNames.length; i++) {
            proposals.push(Proposal({
              name: proposalNames[i],
              voteCount: 0
              }));
        }
    }

    function giveRightToVote(address voter) public {
        require((msg.sender == chairperson) && !voters[vote].voted && (voters[voter].weight == 0));
        voters[voter].weight = 1;
    }

    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted);
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender);
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate = voters[to];
        if (delegate.voted) {
            proposals[delegate.vote].voteCount += sender.weight;
        } else {
            delegate.weight += sender.weight;
        }
    }

    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() public view
        returns (uint winningProposal)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p< proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal = p;
            }
        }
    }

    function winnerName() public view
        returns (bytes32 winnerName)
    {
        winnerName = proposals[winningProposal()].name;
    }
}
