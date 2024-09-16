/*作业请提交在这个目录下*/
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
