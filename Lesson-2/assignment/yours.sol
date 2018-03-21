/*作业请提交在这个目录下*/
//（一）课程代码

﻿pragma solidity ^0.4.14;
contract Payroll{
    //定义雇员结构体
    struct Employee{
        address id;
        uint salary;
        uint lastPayDay;
    }
    
    uint constant payDuration=10 seconds;
    
    address owner;
    Employee[] employees;
    
    function Payroll(){
        owner=msg.sender;
    }
    
    //结构体默认私有，但是solidity中默认可视度为public，应强调私有
    function _partialPaid(Employee employee) private{
        uint payment = employee.salary * (now - employee.lastPayDay) / payDuration;
        employee.id.transfer(payment);
    }
    
    function _findEmployee(address employeeId) private returns (Employee,uint){
        for(uint i=0;i<employees.length;i++){
            if(employees[i].id==employeeId){
                return (employees[i],i);
            }
        }
    }
    
    function addEmployee(address employeeId,uint salary){
        require(msg.sender==owner);
        
	//var可以是任何类型数据的类型修饰符
        var (employee,index) = _findEmployee(employeeId);
        assert(employee.id==0x0);
        
        employees.push(Employee(employeeId,salary*1 ether,now));
    }
    
    function removeEmployee(address employeeId){
        require(msg.sender==owner);
        
        //移除前先结算工资
        var (employee,index) = _findEmployee(employeeId);
        assert(employee.id!=0x0);
        
        _partialPaid(employee);
        delete employees[index];
	//避免数组空间浪费
        employees[index]=employees[employees.length-1];
        employees.length-=1;
    }

    function updateEmployee(address employeeId,uint salary){
        require(msg.sender==owner);
        var (employee,index) = _findEmployee(employeeId);
        assert(employee.id!=0x0);
        
	//更新之前先结算
        _partialPaid(employee);
        employees[index].salary = salary*=1 ether;
        employees[index].lastPayDay = now;
        return;
    }
    
    function addFund() payable returns (uint){
        return this.balance;
    }
    
    //随着employee人数的增加，计算totalSalary时每次都要多进行一次运算
    function calculateRunway() returns (uint){
        uint totalSalary=0;
        for(uint i=0;i<employees.length;i++){
            totalSalary+=employees[i].salary;
        }
        return this.balance/totalSalary;
    }
    
    function hasEnoughFund() returns (bool){
        return calculateRunway()>0;
    }
    
    function getPaid(){
        var (employee,index) = _findEmployee(msg.sender);
        assert(employee.id!=0x0);
        
        uint nextPayDay=employee.lastPayDay+payDuration;
        assert(nextPayDay<now);
        
        employees[index].lastPayDay=nextPayDay;
        employee.id.transfer(employee.salary);
    }
}

//gas记录变化

/*
第一次：
transaction cost:22966 gas
execution cost:1694 gas

第二次：
transaction cost:23747 gas
execution cost:2475 gas

第三次：
transaction cost:24528 gas
execution cost:3256 gas

第四次：
transaction cost:25309 gas
execution cost:4037 gas

第五次：
transaction cost:26090 gas
execution cost:4818 gas

第六次：
transaction cost:26871 gas
execution cost:5599 gas

第七次：
transaction cost:27652 gas
execution cost:6380 gas

第八次：
transaction cost:28422 gas
execution cost:7161 gas

第九次：
transaction cost:29214 gas
execution cost:7942 gas

第十次：
transaction cost:29995 gas
execution cost:8723 gas

结论：transaction gas和execution gas都在不断增加
原因：totalSalary为局部变量，随着employee人数的增加，在calRunAway()中每次都要多进行一次计算
改进方法:将total设置为全局变量，在addEmployee()中进行同步
*/


//优化代码:
pragma solidity ^0.4.14;
contract Payroll{
    
    struct Employee{
        address id;
        uint salary;
        uint lastPayDay;
    }
    
    //设定为全局变量
    uint totalSalary;
    
    uint constant payDuration=10 seconds;
    
    address owner;
    Employee[] employees;
    
    function Payroll(){
        owner=msg.sender;
    }
    
    function _partialPaid(Employee employee) private{
        uint payment = employee.salary * (now - employee.lastPayDay) / payDuration;
        employee.id.transfer(payment);
    }
    
    function _findEmployee(address employeeId) private returns (Employee,uint){
        for(uint i=0;i<employees.length;i++){
            if(employees[i].id==employeeId){
                return (employees[i],i);
            }
        }
    }
    
    function addEmployee(address employeeId,uint salary){
        require(msg.sender==owner);
        
        var (employee,index) = _findEmployee(employeeId);
        assert(employee.id==0x0);
        
        employees.push(Employee(employeeId,salary*1 ether,now));
        //更新totalSalary
        totalSalary+=salary;
    }
    
    function removeEmployee(address employeeId){
        require(msg.sender==owner);
        
        var (employee,index) = _findEmployee(employeeId);
        assert(employee.id!=0x0);
        
        _partialPaid(employee);
        delete employees[index];
        employees[index]=employees[employees.length-1];
        employees.length-=1;
    }

    function updateEmployee(address employeeId,uint salary){
        require(msg.sender==owner);
        var (employee,index) = _findEmployee(employeeId);
        assert(employee.id!=0x0);
        
        _partialPaid(employee);
        employees[index].salary = salary*=1 ether;
        employees[index].lastPayDay = now;
        return;
    }
    
    function addFund() payable returns (uint){
        return this.balance;
    }
    
    //更新
    function calculateRunway() returns (uint){
        return this.balance/totalSalary;
    }
    
    function hasEnoughFund() returns (bool){
        return calculateRunway()>0;
    }
    
    function getPaid(){
        var (employee,index) = _findEmployee(msg.sender);
        assert(employee.id!=0x0);
        
        uint nextPayDay=employee.lastPayDay+payDuration;
        assert(nextPayDay<now);
        
        employees[index].lastPayDay=nextPayDay;
        employee.id.transfer(employee.salary);
    }
}


/*
改进后两种gas变为一个定值
transaction cost:22124 gas
execution cost:852 gas
*/


