// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Fundraiser {
    address public admin;
    uint256 public noOfContributors;
    uint256 public minimumContribution;
    uint256 public deadline; // this is a timestamp
    uint256 public goal; //
    uint256 public raisedAmount = 0;
    mapping(address => uint256) public contributors;

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    struct Request {
        string description;
        address recipient;
        uint256 value;
        bool completed;
        uint256 noOfVoters;
        mapping(address => bool) voters;
    }

    Request[] public requests;

    event ContributeEvent(address sender, uint256 value);
    event CreateRequestEvent(string _description, address _recipient, uint256 _value);
    event MakePaymentEvent(address recipient, uint256 value);

    constructor(uint256 _goal, uint256 _deadline) {
        goal = _goal;
        deadline = block.timestamp + _deadline;
        admin = msg.sender;
        minimumContribution = 10;
    }

    function contribute() public payable {
        require(block.timestamp < deadline && msg.value >= minimumContribution);

        if (contributors[msg.sender] == 0) {
            noOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
        emit ContributeEvent(msg.sender, msg.value);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getRefund() public {
        require(block.timestamp > deadline && raisedAmount < goal && contributors[msg.sender] > 0);
        address payable recipient = payable(msg.sender);
        uint256 value = contributors[msg.sender];
        recipient.transfer(value);
        contributors[msg.sender] = 0;
    }

    function createRequest(
        string memory _description,
        address _recipient,
        uint256 _value
    ) public onlyAdmin {
        Request storage newRequest = requests.push();

        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;

        emit CreateRequestEvent(_description, _recipient, _value);
    }

    function voteRequest(uint256 index) public {
        require(contributors[msg.sender] > 0);
        Request storage thisRequest = requests[index];

        require(thisRequest.voters[msg.sender] == false);

        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint256 index) public onlyAdmin {
        Request storage thisRequest = requests[index];
        require(thisRequest.completed == false);
        require(thisRequest.noOfVoters > noOfContributors / 2);
        payable(thisRequest.recipient).transfer(thisRequest.value);
        thisRequest.completed = true;
        emit MakePaymentEvent(thisRequest.recipient, thisRequest.value);
    }
}
