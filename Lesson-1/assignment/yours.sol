/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract PayrollHomeWork {
    address employee ;
    address owner;
	uint salary = 1 wei;

    uint constant payDuation = 10 seconds;
    uint lastPayday = now;

    function PayrollHomeWork() {
        owner = msg.sender;
    }

    function addfurd() payable returns (uint) {
        return this.balance ;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() {
        // 只有员工自己可以领自己的工资
        if( employee != 0x0 && msg.sender != employee ){
            revert();
        }
        // 不能在发薪周期内多次领取
        uint nextPayDay = lastPayday + payDuation;
        if (nextPayDay > now){
            revert();
        }

        // reentry attacks ？
        lastPayday = nextPayDay;
        employee.transfer(salary);
        // 这里是不是需要从公司账户里减去已发给员工的工资呢？
    }

    // test
    function checkBalance (address addr) returns (uint) {
        return addr.balance;
    }
    
    //作业要求添加的部分
    function updateEmployeeAndSalary(address _employee, uint _salary) {
        if(_employee == 0x0 || _salary == 0) {
            revert();
        }
        employee = _employee;
        salary = _salary * 1 ether;
        lastPayday = now;
    }
}
