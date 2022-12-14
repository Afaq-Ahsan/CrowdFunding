
// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

contract CrowdFunding{
    
    mapping(address=>uint) public contributors;    //who contributes in funding
    address public manager;  //Owner

    uint public minimumContribution;      //minimum contribution a person can fund
    uint public deadline;                 //deadline time
    uint public target;                   //how much target Owner want
    uint public raisedamount;             //total money
    uint public noOfContributors;         //holders

   struct Request{                        //Owner requests for withdraw amount but he/she only with
       string description;               // At particular time when most of contibutors give him 
       address payable recipient;       //permission
       uint value;
       bool completed;
       uint noOfVoters;
       mapping(address=>bool) voters;
   }

   mapping(uint=>Request) public requests;
   uint public noRequests;


    constructor(uint _target,uint _deadline){
  
       target = _target;
       deadline=block.timestamp + _deadline;
       minimumContribution = 100 wei;
       manager = msg.sender;  
    }


    receive() external payable {} 
    fallback() external payable{}  

function sendEth() public payable{
    require(block.timestamp <= deadline,"times up");   
    require(msg.value >= minimumContribution,"minimum contribution is 100 wei");   
    if(contributors[msg.sender]==0)
    {
    noOfContributors++;
    }
    contributors[msg.sender]=msg.value;
    raisedamount+=msg.value;
        
    }
function getContractBalance() public view returns(uint){
    return address(this).balance;
}

function reFund() public{
    require(block.timestamp > deadline && raisedamount < target,"you are not elegible");
    require(contributors[msg.sender] > 0,"Sir you dont have any contribution yet");
    address payable user = payable(msg.sender);
    user.transfer(contributors[msg.sender]);
    contributors[msg.sender] = 0;
    raisedamount = address(this).balance;

    
}
modifier onlyManager(){
    require(msg.sender == manager,"only manager can call");
    _;
}

function create_request(string memory _description,address payable _recipient,uint _value)
public onlyManager{
     //struct           object      mapping      uint
       Request storage newRequest = requests[noRequests]; //Request is struct
       newRequest.description = _description;
       newRequest.recipient = _recipient;
       newRequest.value = _value;
       newRequest.completed = false;
       newRequest.noOfVoters = 0;

}

function voting(uint request_no) public{
    //               mapping outside       
    require(contributors[msg.sender] > 0,"first contribute some then you will be able to vote");
   //struct           object      mapping inside struct          
    Request storage thisRequest = requests[request_no];
                   //   mapping inside struct            
    require(thisRequest.voters[msg.sender] == false ,"you already voted");
            //  mapping of struct
    thisRequest.voters[msg.sender] = true;
    thisRequest.noOfVoters++;
}

function makePayment(uint request_num) public onlyManager{
//state variable\total amount  >= target
    require(raisedamount >= target,"amount is not reached to the target");
//   struct          obj          mapping inside struct 
    Request storage thisRequest = requests[request_num]; 
    require(thisRequest.completed == false,"already completed");
    require(thisRequest.noOfVoters >= noOfContributors/2,"you need to have votes of half contributors");
    thisRequest.recipient.transfer(thisRequest.value);
    thisRequest.completed = true;
}

}
