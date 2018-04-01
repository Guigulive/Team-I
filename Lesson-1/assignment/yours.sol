/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract Payroll {
    uint salary = 1 ether;
    address employee = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    uint constant payDuration = 10 seconds;
    uint lastPayDay = now;
    address owner;
    
    function Payroll() {
        owner = msg.sender;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        if (msg.sender != employee) {
            revert();
        }
        uint nextPayDay = lastPayDay + payDuration;
        if (nextPayDay > now) {
            revert();
        }
        lastPayDay = nextPayDay;
        // 这里一次只能领一个月的工资，而下面的更改员工地址可以一次性把当前没拿的工资一起打到更改前的地址
        employee.transfer(salary);
    }
    
    // 得到员工地址
    function getEmployeeBalance() returns (uint) {
        return employee.balance;
    }
    
    // 得到使用者地址
    function getSenderAddress() returns (address) {
        return msg.sender;
    }
    
    // 更改员工地址
    function updateEmployeeAddress(address e) {
    	// 确认是owner进行操作
        require(msg.sender == owner);
        if (e != 0x0) {
        	// 一次性给予完当前地址没有领完的钱，注意这里有可能一次性给不止一个月的工资，如果相当长的时间一直没有领的话
            uint payment = salary * (now - lastPayDay) / payDuration;
            employee.transfer(payment);
        }
        // 更改员工地址
        employee = e;
        lastPayDay = now;
    }
    
    // 更改员工工资
    function updateEmployeeSalary(uint s) {
        require(msg.sender == owner);
        uint payment = salary * (now - lastPayDay) / payDuration;
        employee.transfer(payment);
        // 更改员工工资
        salary = s * 1 ether;
        lastPayDay = now;
    }
}
