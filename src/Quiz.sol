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
    mapping(address => uint256) public to_give;
    address public owner;
    uint current_quiz_num;
    uint public vault_balance;
    Quiz_item[] public qs;

    receive() external payable {
        vault_balance += msg.value;
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
        require(owner == msg.sender, "not same");
        require(q.id > current_quiz_num, "Invalid adding Quiz ID!");
        qs.push(q);
        ++current_quiz_num;
        if (bets.length < current_quiz_num)
            bets.push();
        return q.id;
    }

    function getAnswer(uint quizId) public view returns (string memory){
        require(owner == msg.sender, "Unathorized!");
        return qs[quizId - 1].answer;
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
    
    function betToPlay(uint quizId) public payable{
        require(quizId <= current_quiz_num, "Invalid Quiz ID!");
        uint rest_bet = bets[quizId - 1][msg.sender];
        Quiz_item memory temp = qs[quizId - 1];
        require(rest_bet + msg.value <= temp.max_bet, "Decrease your bet!");
        require(msg.value >= temp.min_bet, "More betting!");
        require((rest_bet + msg.value) * 2 <= vault_balance, "Lack of Deposit");
        bets[quizId - 1][msg.sender] += msg.value;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        require(quizId <= current_quiz_num, "Invalid Quiz ID!");
        require(bets[quizId - 1][msg.sender] > 0, "Plz bet!");
        Quiz_item memory temp = qs[quizId - 1];
        uint len_1 = bytes(ans).length;
        uint len_2 = bytes(temp.answer).length;
        if (len_1 != len_2)
        {
            vault_balance += bets[quizId - 1][msg.sender];
            bets[quizId - 1][msg.sender] = 0;
            return false;
        }
        for (uint i = 0; i < len_2; ++i)
        {
            if (len_1 != len_2 || bytes(ans)[i] != bytes(temp.answer)[i])
            {
                vault_balance += bets[quizId - 1][msg.sender];
                bets[quizId - 1][msg.sender] = 0;
                return false;
            }
        }
        to_give[msg.sender] += (bets[quizId - 1][msg.sender] * 2);
        return true;
    }

    function claim() public {
        if (to_give[msg.sender] > 0 && vault_balance >= to_give[msg.sender])
        {
            (msg.sender).call{value: to_give[msg.sender]}("");
            to_give[msg.sender] = 0;
        }
    }

}
