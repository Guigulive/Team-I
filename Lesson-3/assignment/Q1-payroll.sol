pragma solidity ^0.4.14;

import "./SafeMath.sol";
import "./Ownable.sol";

contract Payroll is Ownable {
    using SafeMath for uint;
    
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;
    
    address owner;
    mapping(address => Employee) public employees;
    uint totalSalary;
    
    modifier employeeExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }
    
    function _partialPay(Employee employee) private {
        //uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        uint payment = employee.salary.mul(now.sub(employee.lastPayday)).div(payDuration);
        employee.id.transfer(payment);
    }

    function addEmployee(address employeeId, uint salary) onlyOwner {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        
        // Update the total salary
        //totalSalary += salary * 1 ether;
        totalSalary = totalSalary.add(salary * 1 ether);
        employees[employeeId] = Employee(employeeId, salary * 1 ether, now);
    }
    
    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId) {
        var employee = employees[employeeId];
        
        _partialPay(employee);
        // Update the total salary
        //totalSalary -= employee.salary;
        totalSalary = totalSalary.sub(employee.salary);
        // the entry removed from mapping anf set as initial value
        delete employees[employeeId];
    }
    
    function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId) {
        var employee = employees[employeeId];

        _partialPay(employee);
        // Update the total salary
        //totalSalary -= employees[employeeId].salary;
        totalSalary = totalSalary.sub(employees[employeeId].salary);
                
        employees[employeeId].salary = salary * 1 ether;
        // Update the total salary
        //totalSalary += employees[employeeId].salary;
        totalSalary = totalSalary.add(employees[employeeId].salary);
        employees[employeeId].lastPayday = now;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        //return this.balance / totalSalary;
        return this.balance.div(totalSalary);
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function checkEmployee(address employeeId) returns (uint salary, uint lastPayday) {
        var employee = employees[employeeId];
        salary = employee.salary;
        lastPayday = employee.lastPayday;
    }
    
    function getPaid() employeeExist(msg.sender) {
        //get the reference to the entry in mapping
        var employee = employees[msg.sender];
        
        //uint nextPayday = employee.lastPayday + payDuration;
        uint nextPayday = employee.lastPayday.add(payDuration);
        assert(nextPayday < now);
        
        employees[msg.sender].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}
