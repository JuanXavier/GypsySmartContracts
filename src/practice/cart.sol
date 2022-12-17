// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./exam.sol";
import "./library.sol";

interface CourseInterface {
    function getCourseById(uint256 index)
        external
        view
        returns (
            uint256 _id,
            uint256 _price,
            string memory title
        );
}

error No_Recipient();
error Empty_Amount();
error Low_Balance();
error Invalid_Address();

contract Cart is Exam {
    uint256[] public cart;
    address public courseAddress;
    mapping(address => uint256) public studentExam;
    address[] public keys;
    mapping(address => uint256) internal balance;
    mapping(address => uint256[]) public myCourse;
    mapping(address => bool) public inserted;
    mapping(address => mapping(address => bool)) public isPaid;
    event BalanceAdded(uint256 amount, address indexed depositTo);
    event TransferSuccess(address indexed sender, address indexed reciever, uint256 amount);
    event FallbackLog(string func, address sender, uint256 value, bytes data);
    event ReceiveLog(uint256 amount, uint256 gas);

    constructor(address _courseAddress) {
        courseAddress = _courseAddress;
    }

    function chooseCoursesToBuy(uint256 index) public returns (uint256[] memory) {
        cart.push(index); //put id of course
        return cart;
    }

    function viewCart() public view returns (uint256[] memory) {
        return cart;
    }

    function removeCourseToBuy(uint256 index) public returns (uint256[] memory) {
        //move index to last index for pop
        //solidity cannot use "delete cart[1]" because array lenght not change from immutable
        cart[index] = cart[cart.length - 1];
        cart.pop();
        return cart;
    }

    function calculateTotalPrice() public view returns (uint256 _totalPrice) {
        CourseInterface c = CourseInterface(courseAddress);
        uint256 totalPrice = 0;
        //cart have index [1,2] ,loop start from uint i=0, loop 0,1
        for (uint256 i = 0; i < cart.length; i++) {
            (, uint256 _price, ) = c.getCourseById(cart[i]);
            totalPrice += _price;
        }
        return totalPrice;
    }

    function payCourse(address _recipient) public returns (bool) {
        uint256 amount = calculateTotalPrice();
        address recipient = _recipient;
        if (recipient == address(0)) {
            revert No_Recipient();
        }
        if (msg.sender == recipient) {
            revert Invalid_Address();
        }
        if (amount == 0) {
            revert Empty_Amount();
        }
        if (balance[msg.sender] < amount) {
            revert Low_Balance();
        }
        _transfer(msg.sender, recipient, amount);
        addMyCourse(msg.sender);
        isPaid[msg.sender][recipient] = true;
        clearCart();
        emit TransferSuccess(msg.sender, recipient, amount);
        return true;
    }

    function clearCart() public returns (uint256[] memory) {
        delete cart;
        return cart;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        balance[from] -= amount;
        balance[to] += amount;
    }

    function addBalance(uint256 _toAdd) public returns (uint256) {
        balance[msg.sender] = balance[msg.sender] + _toAdd;
        emit BalanceAdded(_toAdd, msg.sender);
        return balance[msg.sender];
    }

    function getBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

    function depositContract() public payable returns (uint256) {
        balance[address(this)] += msg.value;
        balance[msg.sender] -= msg.value;
        return Finance.getBalanceContract();
    }

    function getStatusPaid(address receiver) public view returns (bool) {
        return isPaid[msg.sender][receiver];
    }

    //addMyCourse when student complete payment
    function addMyCourse(address _student) private {
        uint256[] memory courseID = viewCart();
        myCourse[_student] = courseID;
        if (!inserted[_student]) {
            inserted[_student] = true;
            keys.push(_student);
        }
    }

    //return course id that student already paid, this course id can use for loop in other function
    function getMyCourse() public view returns (uint256[] memory) {
        return myCourse[msg.sender];
    }

    function getAllStudents() public view returns (address[] memory) {
        return keys;
    }

    //when somebody try to call non-exist function and sent ether to this contract
    fallback() external payable {
        emit FallbackLog("fallback", msg.sender, msg.value, msg.data);
    }

    //when somebody sent money + empty data to contract
    receive() external payable {
        emit ReceiveLog(msg.value, gasleft());
    }

    function registerExam() public {
        studentExam[msg.sender] = getDefaultStatus();
    }

    function registerRetakeExam() public {
        studentExam[msg.sender] = setReTest();
    }

    function completeExam() private {
        studentExam[msg.sender] = setComplete();
    }

    function getStatusExam() public view returns (uint256) {
        return studentExam[msg.sender];
    }
}
