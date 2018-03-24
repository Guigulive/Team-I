/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {
    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }
    uint constant payDuration = 10 seconds;
    uint totalSalary;
    address owner;
    mapping(address => Employee) public employees;

    // function Payroll() {
    //     owner = msg.sender;
    // }

    // modifier onlyOwner() { require(msg.sender == owner); _;}

    modifier employeeExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }
    modifier employeeNotExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        _;
    }

    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayDay) / payDuration;
        employee.id.transfer(payment);
    }

    function addEmployee(address employeeId, uint salary) onlyOwner {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        employees[employeeId] = Employee(employeeId, salary * 1 ether, now);
        totalSalary += salary * 1 ether;
    }

    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId) payable {
        var employee = employees[employeeId];
        _partialPaid(employee);
        totalSalary -= employees[employeeId].salary;
        delete employees[employeeId];
    }

    function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId) payable {
        var employee = employees[employeeId];
        uint newSalary = salary * 1 ether;
        assert(newSalary != employee.salary);
        _partialPaid(employee);
        totalSalary -= employees[employeeId].salary;
        employees[employeeId].salary     = newSalary;
        employees[employeeId].lastPayDay = now;
    }
    function changePaymentAddress(address employeeNewId) employeeExist(msg.sender) employeeNotExist(employeeNewId) {
        var employee = employees[msg.sender];
        employees[employeeNewId] = Employee({id: employeeNewId, salary: employee.salary, lastPayDay: employee.lastPayDay});
        delete employees[msg.sender];
    }
    function addFund() payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() returns (uint) {
        return this.balance / totalSalary;
    }

    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function checkEmployee(address employeeId) returns (uint salary, uint lastPayDay) {
        var employee = employees[employeeId];
        salary = employee.salary;
        lastPayDay = employee.lastPayDay;
    }

    function getPaid() employeeExist(msg.sender) {
        var employee = employees[msg.sender];
        
        uint nextPayDay = employee.lastPayDay + payDuration;
        assert(nextPayDay < now);

        employees[msg.sender].lastPayDay = nextPayDay;
        employee.id.transfer(employee.salary);
    }
}
