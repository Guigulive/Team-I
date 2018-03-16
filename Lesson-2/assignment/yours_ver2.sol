pragma solidity ^0.4.14;

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;

    address owner;
    Employee[] employees;
    uint totalSalary;

    function Payroll() {
        owner = msg.sender;
    }
    
    function _partialPaid(Employee employee) private {
      if (employee.id != 0x0) {
          uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
          employee.id.transfer(payment);
      }
    }
    
    function _findEmployee(address e) private constant returns (Employee, uint) {
      for(uint i = 0; i < employees.length; i++) {
          if(employees[i].id == e) {
              return (employees[i], i);
          }
      }
    }

    //For debug only
    function getAllEmployees() returns (address[], uint[], uint[]){
      require(msg.sender == owner);
      address[] memory addrs = new address[](employees.length);
      uint[]    memory salays = new uint[](employees.length);
      uint[]    memory lastpds = new uint[](employees.length);
      for (uint i = 0; i < employees.length; i++) {
          Employee storage employee = employees[i];
          addrs[i] = employee.id;
          salays[i] = employee.salary;
          lastpds[i] = employee.lastPayday;
      }
      return (addrs, salays, lastpds);
    }
    //For debug only
    function getBalance() constant returns (uint){
      require(msg.sender == owner);
      return this.balance;
    }
    //For debug only
    function getTotalSalary() constant returns (uint){
      require(msg.sender == owner);
      return totalSalary;
    }


    function addEmployee(address e, uint s) {
      require(msg.sender == owner);
      var (employee, index) = _findEmployee(e);
      assert(employee.id == 0x00);
      employees.push(Employee(e, s * 1 ether, now));

      totalSalary += s * 1 ether;
    }
    
    function removeEmployee(address e) {
      require(msg.sender == owner);
      var (employee, index) = _findEmployee(e);
      assert(employee.id != 0x00);
      delete employees[index];
      employees[index] = employees[employees.length-1];
      employees.length--;

      totalSalary -= employee.salary;

      _partialPaid(employee);
    }
    
    function updateEmployee(address e, uint s) {
      require(msg.sender == owner);
      var (employee, index) = _findEmployee(e);
      assert(employee.id != 0x00);

      uint delta_salary = employee.salary - s * 1 ether;

      employees[index].id = e;
      employees[index].salary = s * 1 ether;
      employees[index].lastPayday = now;

      totalSalary -= delta_salary;

      _partialPaid(employee);
    }
    
    function addFund() payable returns (uint) {
      return this.balance;
    }
    
    function calculateRunway() constant returns (uint) {
        // uint totalSalary = 0;
        // for (uint i = 0; i < employees.length; i++) {
        //     totalSalary += employees[i].salary;
        // }
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() constant returns (bool) {
      return calculateRunway() > 0;
    }
    
    function getPaid() {
      var (employee, index) = _findEmployee(msg.sender);
      assert(employee.id != 0x00);
      
      uint nextPayday = employee.lastPayday + payDuration;
      assert(nextPayday < now);

      employees[index].lastPayday = nextPayday;
      employees[index].id.transfer(employees[index].salary);
    }
}
