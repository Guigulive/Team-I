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
    
    mapping(address=>Employee) employees;
    uint constant payDuration = 10 seconds;
    uint totalSalary;

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
    
    //For debug only
    function getEmployee(address e) returns (address id, uint salary, uint lastPayday) {
      return (employees[e].id,employees[e].salary,employees[e].lastPayday);
    }
    //For debug only
    function getBalance() onlyOwner constant returns (uint) {
      return this.balance;
    }
    //For debug only
    function getTotalSalary() onlyOwner constant returns (uint) {
      return totalSalary;
    }

    function addEmployee(address e, uint s) onlyOwner isNotEmployee(e) {
      employees[e] = Employee(e, s * 1 ether, now);

      totalSalary = totalSalary.add(s * 1 ether);
    }
    
    function removeEmployee(address e) onlyOwner isEmployee(e) {
      var employee = employees[e];
      _partialPaidByAddr(e);
      totalSalary = totalSalary.sub(employee.salary);
      delete employees[e];
    }
    
    function updateEmployee(address e, uint s) onlyOwner isEmployee(e) {
      var employee = employees[e];
      _partialPaidByAddr(e);
      totalSalary = totalSalary.add(s * 1 ether).sub(employee.salary);
      employee.salary = s * 1 ether;
      employee.lastPayday = now;
    }

    function changePaymentAddress(address new_e) isEmployee(msg.sender) isNotEmployee(new_e) {
      var employee = employees[msg.sender];
      _partialPaidByAddr(msg.sender);
      employees[new_e] = Employee(new_e, employee.salary, now);
      delete employees[msg.sender];
    }
    
    function addFund() payable returns (uint) {
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
    }
}
