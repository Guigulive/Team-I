pragma solidity ^0.4.14;

contract Payroll {
    // employer info
    address employer;
    
    // employee info
    // those fileds could be encapsulated into a struct eventually
    uint salary;
    address employee;
    uint lastPayday;
    
    uint constant payDuration = 30 days;
    
    function Payroll() {
        employer = msg.sender;
    }

    function setEmployee(address _employee, uint _salary) {
        // only the employer can decide the salary of employees
        if(msg.sender != employer) {
            revert();
        }
        
        employee = _employee;
        salary = _salary * 1 ether;
        lastPayday = now;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        if(msg.sender != employee) {
            revert();
        }
        
        uint nextPayday = lastPayday + payDuration;
        if(nextPayday > now) {
            revert();
        }
        
        lastPayday = nextPayday;
        employee.transfer(salary);
    }
}
