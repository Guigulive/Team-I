pragma solidity ^0.4.14;

contract Payroll {
    // owner info
    address owner;
    
    // employee info
    // those fileds could be encapsulated into a struct eventually
    uint salary;
    address employee;
    uint lastPayday;
    
    uint constant payDuration = 30 days;
    
    function Payroll() {
        owner = msg.sender;
    }

    function updateEmployee(address _employee, uint _salary) {
        // only the owner can decide the salary of employees
        if(msg.sender != owner) {
            revert();
        }
        
        if(_employee == 0x0) {
            revert();
        }
        
        if(employee != 0x0) {
            // pay the due before the new salary adjustment
            uint payment = (salary * (now - lastPayday)) / payDuration;
            employee.transfer(payment);
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
