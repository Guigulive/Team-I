
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
    
    modifier onlySelf(address employeeId) {
        require(employeeId == msg.sender);
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
        totalSalary = totalSalary.add(salary * 1 ether);
        employees[employeeId] = Employee(employeeId, salary * 1 ether, now);
    }
    
    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId) {
        var employee = employees[employeeId];
        
        _partialPay(employee);
        // Update the total salary
        totalSalary = totalSalary.sub(employee.salary);
        // the entry removed from mapping anf set as initial value
        delete employees[employeeId];
    }
    
    function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId) {
        var employee = employees[employeeId];

        _partialPay(employee);
        // Update the total salary
        totalSalary = totalSalary.sub(employees[employeeId].salary);
                
        employees[employeeId].salary = salary * 1 ether;
        // Update the total salary
        totalSalary = totalSalary.add(employees[employeeId].salary);
        employees[employeeId].lastPayday = now;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance.div(totalSalary);
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function checkEmployee(address employeeId) returns (address id, uint salary, uint lastPayday) {
        var employee = employees[employeeId];
        id = employee.id;
        salary = employee.salary;
        lastPayday = employee.lastPayday;
    }
    
    function getPaid() public employeeExist(msg.sender) {
         //get the reference to the entry in mapping
        var employee = employees[msg.sender];
        
        uint nextPayday = employee.lastPayday.add(payDuration);
        assert(nextPayday < now);
        
        employees[msg.sender].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
     }

    // Only employees themselives can change the paryment address
    function changeEmployeeAddress(address employeeId, address newEmployeeId) public onlyOwner employeeExist(employeeId) {
        var employee = employees[employeeId];

        // There is no entry of new employee in the employee list
        var newEmployee = employees[newEmployeeId];
        assert(newEmployee.id == 0x0);

        _partialPay(employee);
        
        // Add the entry for the new employee
        employees[newEmployeeId] = Employee(newEmployeeId, employee.salary, now);        
        // Delete the entry for the old employee
        delete employees[employeeId];
    }
}
