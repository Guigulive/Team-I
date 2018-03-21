/*
gas变化记录：
22966 gas
23747 gas
24528 gas
25309 gas
26090 gas
26871 gas
27652 gas
28433 gas
29214 gas
29995 gas

问题一：
每次gas的消耗依次递增781，calculateRunway函数每次都执行for循环，所以每执行一次循环体的消耗应该是781 gas。

问题二：可以通过本地变量记录totalSalary，避免calculateRunway函数每次都执行for循环。

gas变化记录：

22124 gas
22124 gas
22124 gas
22124 gas
22124 gas
22124 gas
22124 gas
22124 gas
22124 gas
22124 gas
*/


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
      uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
      employee.id.transfer(payment);
    }

    function _calculatePayment(Employee employee) private returns (uint){
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        return payment;
    }

    function _findEmployee(address employeeId) private returns (Employee, uint) {
        for(uint i = 0; i < employees.length; i++){
          if(employees[i].id == employeeId){
            return (employees[i], i);
          }
        }
    }

    function addEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        var(employee, index)  = _findEmployee(employeeId);
        assert(employee.id == 0x0);
        totalSalary +=salary;
        employees.push(Employee(employeeId, salary, now));
    }

    function removeEmployee(address employeeId) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);

        uint payment = _calculatePayment(employee);
        // 先付钱，再修改本地变量会有安全问题
        // _partialPaid(employee);

        totalSalary -= employees[index].salary;
        delete employees[index];
        employees.length -= 1;
        employeeId.transfer(payment);


    }

    function updateEmployee(address employeeId, uint salary) {
       require(msg.sender == owner);
       var(employee, index) = _findEmployee(employeeId);
       assert(employee.id != 0x0);
       uint payment = _calculatePayment(employee);

       /* _partialPaid(employee); */

       totalSalary += salary - employees[index].salary;
       employees[index].salary = salary;
       employees[index].lastPayday = now;
       employeeId.transfer(payment);

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

    function getPaid() {
        var (employee, index) = _findEmployee(msg.sender);
        require(employee.id != 0x0);

        uint nextPayDay = employee.lastPayday + payDuration;
        assert(nextPayDay < now);

        employees[index].lastPayday = nextPayDay;
        employees[index].id.transfer(employee.salary);
    }
}
