pragma solidity ^0.4.14;
contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }

    uint constant payDuration = 10 seconds;

    address owner;
    uint totalSalary;
    Employee []employees;

    function Payroll() {
        owner = msg.sender;
    }

    modifier isOwner() {
       require(msg.sender == owner);
    }

    function _partialFindEmployee(address employeeId) private returns (Employee, uint) {
        uint len = employees.length;
        for (uint i = 0; i < len; i++) {
            if (employees[i].id == employeeId) {
                return (employees[i], i);
            }
        }
    }

    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayDay) / payDuration;
        employee.id.transfer(payment);
    }

    function addEmployee(address employeeId, uint salary) isOwner {
        var(employee, _) = _partialFindEmployee(employeeId);
        assert(employee.id == 0x0);

        employees.push(Employee(employeeId, salary * 1 ether, now));
        totalSalary += salary;
    }

    function removeEmployee(address employeeId) isOwner {
        var(employee, index) = _partialFindEmployee(employeeId);
        assert(employee.id != 0x0);

        _partialPaid(employee);
        uint len = employees.length;
        delete employees[index];
        employees[index] = employees[len - 1];
        len--;

        totalSalary -= employee.salary;
    }

    function updateEmployee(address employeeId, uint salary) isOwner {
        var(employee, index) = _partialFindEmployee(employeeId);
        assert(employee.id != 0x0);

        uint newSalary = salary * 1 ether;
        assert(newSalary != employee.salary);

        _partialPaid(employee);
        employees[index].salary     = newSalary;
        employees[index].lastPayDay = now;

        totalSalary = totalSalary - employee.salary + salary;
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
        var (employee, index) = _partialFindEmployee(msg.sender);
        assert(employee.id != 0x0);

        uint nextPayDay = employee.lastPayDay + payDuration;
        assert(nextPayDay < now);

        employees[index].lastPayDay = nextPayDay;
        employee.id.transfer(employee.salary);
    }
}
