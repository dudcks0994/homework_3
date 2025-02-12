// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import {console} from "forge-std/console.sol";


contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
    
    mapping(address => uint256)[] public bets;
    mapping(address => uint256) public contributors;
    address public owner;
    uint current_quiz_num;
    uint public vault_balance;
    Quiz_item[] public qs;

    receive() external payable {
        contributors[msg.sender] = msg.value;
    }

    constructor () {
        current_quiz_num = 0;
        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        owner = msg.sender;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public returns (uint){
        require(contributors[msg.sender] > 0 || owner == msg.sender, "not same");
        require(q.id > current_quiz_num, "Invalid adding Quiz ID!");
        qs.push(q);
        ++current_quiz_num;
        return q.id;
    }

    function getAnswer(uint quizId) public view returns (string memory){
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        require(quizId <= current_quiz_num, "Invalid get Quiz ID!");
        Quiz_item memory temp = qs[quizId - 1];
        temp.answer = "";
        return temp;
    }

    function getQuizNum() public view returns (uint){
        return current_quiz_num;
    }
    
    function betToPlay(uint quizId) public payable returns(uint){
        require(quizId <= current_quiz_num, "Invalid Quiz ID!");
        uint len = bets.length;
        uint256 rest_bet;
        if (len < current_quiz_num)
            rest_bet = 0;
        else
            rest_bet = bets[quizId - 1][msg.sender];
        Quiz_item memory temp = qs[quizId - 1];
        console.logUint(rest_bet + msg.value);
        return rest_bet + msg.value;
        // require(rest_bet + msg.value > temp.max_bet, "Decrease your bet!");
        // require(rest_bet + msg.value > contributors[msg.sender], "Put more Deposit!");
        // bets[quizId][msg.sender] += msg.value;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
    }

    function claim() public {
        
    }

}
