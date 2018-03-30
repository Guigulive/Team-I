pragma solidity ^0.4.18;

import "./Ownable.sol";
import "./SafeMath.sol";

contract Payroll is Ownable {
    using SafeMath for uint;

    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }

    mapping(address=>Employee) public employees;
    uint constant payDuration = 10 seconds;
    uint totalSalary;
    uint totalEmployee;
    address[] employeeList;

    event NewEmployee(address employee);
    event UpdateEmployee(address employee);
    event RemoveEmployee(address employee);
    event NewFund(uint balance);
    event GetPaid(address employee);

    modifier isEmployee(address e) {
        var employee = employees[e];
        assert(employee.id != 0x00);
        _;
    }

    modifier isNotEmployee(address e) {
        var employee = employees[e];
        assert(employee.id == 0x00);
        _;
    }

    function _partialPaid(Employee employee) private {
        if (employee.id != 0x0) {
            uint payment = employee.salary.mul((now.sub(employee.lastPayday)).div(payDuration));
            employee.id.transfer(payment);
        }
    }

    function _partialPaidByAddr(address e) isEmployee(e) private {
        var employee = employees[e];
        uint payment = employee.salary.mul((now.sub(employee.lastPayday)).div(payDuration));
        employee.id.transfer(payment);
    }

    function _findEmployee(address employeeId) private returns (address, uint){
        for(var i=0;i<employeeList.length;i++){
            if(employeeList[i] == employeeId){
                return (employeeList[i], i);
            }
        }
    }

    //For debug only
    function getEmployee(address e) returns (address id, uint salary, uint lastPayday) {
        return (employees[e].id,employees[e].salary,employees[e].lastPayday);
    }
    //For debug only
    function getEmployeeId(address e) returns (address id) {
        return employees[e].id;
    }
    //For debug only
    function getBalance() onlyOwner constant returns (uint) {
        return this.balance;
    }
    //For debug only
    function getTotalSalary() onlyOwner constant returns (uint) {
        return totalSalary;
    }
    //For debug only
    function getOwner() constant returns (address) {
        return owner;
    }

    function checkEmployee(uint index) returns (address employeeId, uint salary, uint lastPayday) {
        employeeId = employeeList[index];
        var employee = employees[employeeId];
        salary = employee.salary;
        lastPayday = employee.lastPayday;
    }

    function addEmployee(address e, uint s) onlyOwner isNotEmployee(e) {
        employees[e] = Employee(e, s.mul(1 ether), now);
        totalSalary = totalSalary.add(s.mul(1 ether));
        totalEmployee = totalEmployee.add(1);
        employeeList.push(e);
        NewEmployee(e);
    }

    function removeEmployee(address e) onlyOwner isEmployee(e) {
        var employee = employees[e];
        _partialPaidByAddr(e);
        totalSalary = totalSalary.sub(employee.salary);
        delete employees[e];
        totalEmployee = totalEmployee.sub(1);
        //Update employeeList
        var (employee_temp_address, index) = _findEmployee(e);
        assert(index>=0);
        employeeList[index] = employeeList[employeeList.length-1];
        employeeList.length -= 1;
        RemoveEmployee(e);
    }

    function updateEmployee(address e, uint s) onlyOwner isEmployee(e) {
        var employee = employees[e];
        _partialPaidByAddr(e);
        totalSalary = totalSalary.add(s.mul(1 ether)).sub(employee.salary);
        employee.salary = s.mul(1 ether);
        employee.lastPayday = now;
        UpdateEmployee(e);
    }

    function changePaymentAddress(address new_e) isEmployee(msg.sender) isNotEmployee(new_e) {
        var employee = employees[msg.sender];
        _partialPaidByAddr(msg.sender);
        employees[new_e] = Employee(new_e, employee.salary, now);
        delete employees[msg.sender];
    }

    function addFund() payable returns (uint) {
        NewFund(this.balance);
        return this.balance;
    }

    function calculateRunway() constant returns (uint) {
        return this.balance.div(totalSalary);
    }

    function hasEnoughFund() constant returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() isEmployee(msg.sender) {
        var employee = employees[msg.sender];

        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);

        employee.lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
        GetPaid(employee.id);
    }

    function checkInfo() returns (uint balance, uint runway, uint employeeCount) {
        balance = this.balance;
        employeeCount = totalEmployee;

        if (totalSalary > 0) {
            runway = calculateRunway();
        }
    }
}
