pragma solidity ^0.4.22;

contract WWFCryptoBisons {
  // this is our structure for name proposals,
  // it contains a "name" variable with the proposed name 
  // and a "sumPayments" variable with the total sum paid for this name 
  struct NameProposal {
      bytes32 name;
      uint256 sumPayments;
  }
  
  // this is a big map of name proposals. The variable is called "arrProposedNames".
  // the map is mapping a hash of the name to the NameProposal structure we defined above
  mapping(bytes32 => NameProposal) arrProposedNames;
  
  // this is an array of map keys we have received, we need it so we can later
  // iterate over it when we want to export a list of all proposed names in 
  // the getVotes() function
  bytes32[] arrMapKeys;
    
  // this is the hardcoded address of WWF where all the money that is sent
  // to this smart contract is forwarded to
  address WWFAddress = 0x5ba93ce3a2dd006e05f87b65a27d4e5f8d0a4b20;

  // this function allows blockchain users to vote for a name
  function voteForName(bytes32 proposedName) public payable {
      // make sure name has at least 3 characters
      require(proposedName.length > 3, 'pls a name of 3 to 32 characters');
      
      // create hash from the proposed name so we can use it as key for our map
      bytes32 hashedName = keccak256(proposedName);
      
      // make sure payment amount is larger than zero
      require(msg.value > 0, 'To cast a vote, pay you must.');
      
      // now we need to check if the name has already been proposed.
      // if yes, we need to increase existing amount, if no we need to create new
      // entry for this name proposal
      if (arrProposedNames[hashedName].sumPayments != 0) {
        // this is a name we already know, so add the payment amount to the existing sum
        arrProposedNames[hashedName].sumPayments = arrProposedNames[hashedName].sumPayments + msg.value;
      } else {
        // this is a new name, so we need to store map key in array
        arrMapKeys.push(hashedName);

        // create a new name proposal structure with "sumPayments" and "proposedName" variables
        NameProposal memory newNameProposal;
        newNameProposal.sumPayments = msg.value;
        newNameProposal.name = proposedName;
      
        // store name proposal persistently in the smart contract
        arrProposedNames[hashedName] = newNameProposal;
      }
      
      // forward the payment amount to the WWF address and make sure it was successful
      require(WWFAddress.send(msg.value), 'money could not be forwarded');
  }

  // this function returns all proposed names and sum of payments for each name
  function getVotes() constant returns (bytes32[], uint256[]) {
    uint length = arrMapKeys.length;

    bytes32[] memory arrNames = new bytes32[](length);
    uint256[] memory arrPayments = new uint256[](length);

    for (uint i = 0; i < length; i++) {
      arrNames[i] = arrProposedNames[arrMapKeys[i]].name;
      arrPayments[i] = arrProposedNames[arrMapKeys[i]].sumPayments;
    }

    return (arrNames, arrPayments);
  }
}