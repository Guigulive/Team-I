pragma solidity ^0.4.14;


import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {

    //SafeMath.sol中各种运算的参数类型都是uint256，不修改会报错
    using SafeMath for uint256;
    
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;
    //设为全局变量，减少GAS消耗
    uint totalSalary;
    address owner;
    //便于通过地址访问employee
    mapping(address => Employee) public employees;
    
    //为了简化下面代码，采用了MODIFIER
    modifier employeeExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }
    
    //新增：可用在addEmployee和changePaymentAddress中
    modifier employeeNotExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        _;
    }
    
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary.mul(now.sub(employee.lastPayday).div(payDuration));
        employee.id.transfer(payment);
    }

    function addEmployee(address employeeId, uint salary) public onlyOwner employeeNotExist(employeeId) {
        employees[employeeId] = Employee(employeeId, salary.mul(1 ether), now);
        totalSalary = totalSalary.add(employees[employeeId].salary);
    }
    
    function removeEmployee(address employeeId) public onlyOwner employeeExist(employeeId) {
        var employee = employees[employeeId];
        _partialPaid(employee);
        totalSalary = totalSalary.sub(employees[employeeId].salary);
        delete employees[employeeId];
    }
    
    function updateEmployee(address employeeId, uint salary) public onlyOwner employeeExist(employeeId) {
        var employee = employees[employeeId];
        _partialPaid(employee);
        totalSalary = totalSalary.sub(employees[employeeId].salary);
        employees[employeeId].salary = salary.mul(1 ether);
        employees[employeeId].lastPayday = now;
        totalSalary = totalSalary.add(employees[employeeId].salary);
    }
    
    function addFund() payable public returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() view public returns (uint) {
        return this.balance.div(totalSalary);
    }
    
    function hasEnoughFund() view public returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() public employeeExist(msg.sender) {
        var employee = employees[msg.sender];
        
        uint nextPayDay = employee.lastPayday.add(payDuration);
        assert(nextPayDay < now);
        
        employees[msg.sender].lastPayday = nextPayDay;
        employee.id.transfer(employee.salary);
    }
    
    function changePaymentAddress(address oldEmployeeId, address newEmployeeId) onlyOwner employeeExist(oldEmployeeId) employeeNotExist(newEmployeeId) public {
        var employee = employees[oldEmployeeId];
        _partialPaid(employee);
        employee.id = newEmployeeId;
        employees[newEmployeeId] = employee;
        delete employees[oldEmployeeId];
    }
}
