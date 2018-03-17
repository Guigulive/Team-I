pragma solidity ^0.4.14;

contract Payroll{
    uint salary;
    address employee;
    address owner;
    uint constant payDuration = 30 days;
    uint lastPayday = now;

    function Payroll (){

        owner = msg.sender;
    }

    function addFund() payable returns (uint) {
        return this.balance;

    }

    function calculateRunway() returns (uint){
        return this.balance / salary;
    }

    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }

    function getPay() {
        require(msg.sender == employee);

        uint nextPayday = lastPayday + payDuration;
        assert(nextPayday < now);

        lastPayday = nextPayday;
        employee.transfer(salary);

    }

    function updateSalary(uint s) {
        require(msg.sender == owner);

        if(employee != 0x0){
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }

        salary = s;
        lastPayday = now;
    }


    function updateEmployee(address e) {
        require(msg.sender == owner);

        if(employee != 0x0){
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }

         employee = e;
         lastPayday = now;
    }

    function updateEmployeeAndSalary (address e, uint s) {
        require(msg.sender == owner);

        if(employee != 0x0){
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }

        employee = e;
        salary = s;
        lastPayday = now;

    }
}
