/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }
    uint constant payDuration = 10 seconds;
    uint totalSalary;
    address owner;
    mapping(address => Employee) employees;

    function Payroll() {
        owner = msg.sender;
    }

    modifier isOwner() {
       require(msg.sender == owner);
       _;
    }

    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayDay) / payDuration;
        employee.id.transfer(payment);
    }

    function addEmployee(address employeeId, uint salary) isOwner {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        employees[employeeId] = Employee(employeeId, salary * 1 ether, now);
        totalSalary += salary * 1 ether;
    }

    function removeEmployee(address employeeId) isOwner {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _partialPaid(employee);
        totalSalary -= employees[employeeId].salary;
        delete employees[employeeId];
    }

    function updateEmployee(address employeeId, uint salary) isOwner {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        uint newSalary = salary * 1 ether;
        assert(newSalary != employee.salary);
        _partialPaid(employee);
        totalSalary -= employees[employeeId].salary;
        employees[employeeId].salary     = newSalary;
        employees[employeeId].lastPayDay = now;
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

    function getPaid() {
        var employee = employees[msg.sender];
        assert(employee.id != 0x0);
        uint nextPayDay = employee.lastPayDay + payDuration;
        assert(nextPayDay < now);

        employees[msg.sender].lastPayDay = nextPayDay;
        employee.id.transfer(employee.salary);
    }
}
