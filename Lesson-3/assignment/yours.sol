/*作业请提交在这个目录下*/
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
    
    function calculateRunway() returns (uint) {
        return this.balance.div(totalSalary);
    }
    
    function hasEnoughFund() returns (bool) {
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
/*
第一题:见代码，见截图，为了安全性，导入了SafeMath，同时对代码中所有的四则运算做了修改。
为了简化代码，用了onlyOwner，同时有一个疑问:changePaymentAddress唯一的可执行者是否应该是oldEmployeeId?
如果唯一的可执行者是雇主（合约部署者）的话，合约的部署者完全可以自己开小号， 把地址改成自己的小号，黑掉员工的钱

第二题：代码如上，编写了更改员工地址的changePaymentAddress函数，同时编写了modifier employeeNotExist，可以用来确认员工地址不存在
可用在addEmployee和changePaymentAddress中
对于changePaymentAddress函数，注意的有两点：
1.函数执行时切换为合约的部署者，领钱时切换为新的地址
2.即使改变了地址，原地址还是存在，还是应该及时remove


第三题：C3 Linearization
L(O) := [O]
L(A) := [A] + merge(L(O), [O])
      = [A] + merge([O], [O])
      = [A, O]

L(B) := [B, O]
L(C) := [C, O]

L(K1) := [K1] + merge(L(B), L(A), [B, A])
       = [K1] + merge([B, O], [A, O], [B, A])
       = [K1, B] + merge([O], [A, O], [A])
       = [K1, B, A] + merge([O], [O])
       = [K1, B, A, O]

L(K2) := [K2] + merge(L(C), L(A), [C, A])
       = [K2] + merge([C, O], [A, O], [C, A])
       = [K2, C] + merge([O], [A, O], [A])
       = [K2, C, A] + merge([O], [O])
       = [K2, C, A, O]

 L(Z) := [Z] + merge(L(K2), L(K1), [K2, K1])
       = [Z] + merge([K2, C, A, O], [K1, B, A, O], [K2, K1])
       = [Z, K2] + merge([C, A, O], [K1, B, A, O], [K1])
       = [Z, K2, C] + merge([A, O], [K1, B, A, O], [K1])
       = [Z, K2, C, K1] + merge([A, O], [B, A, O])
       = [Z, K2, C, K1, B] + merge([A, O], [A, O])
       = [Z, K2, C, K1, B, A] + merge([O], [O])
       = [Z, K2, C, K1, B, A, O]
*/
