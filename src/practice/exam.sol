// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Exam {
    enum ExamStatus {
        waiting,
        retest,
        complete
    }
    ExamStatus public status;
    ExamStatus public constant DEFAULT_STATUS = ExamStatus.waiting;

    //status =1
    function setReTest() public returns (uint256) {
        status = ExamStatus.retest;
        return uint256(status);
    }

    //status =2
    function setComplete() public returns (uint256) {
        status = ExamStatus.complete;
        return uint256(status);
    }

    function getExamStatus() public view returns (ExamStatus) {
        return status;
    }

    //status =0
    function getDefaultStatus() public pure returns (uint256) {
        return uint256(DEFAULT_STATUS);
    }
}
