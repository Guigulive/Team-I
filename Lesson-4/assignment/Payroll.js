/*作业请提交在这个目录下*/
var Payroll = artifacts.require("./Payroll.sol");

//测试addEmployee
contract('Payroll_addEmployee', function(accounts) {

  //测试执行者是否为owner
  it("Test other user  to add employee", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      return payrollInstance.addEmployee(accounts[1], 2, {from: accounts[2]});
    }).catch( function(error) {
        assert.include(error.toString(),"revert", "Error!!: other user can add employee");
    });
  });

  //测试被添加的员工是否已经存在
  it("Test add an exist employee", function() {
    return Payroll.deployed().then(function(instance) {
    payrollInstance = instance;
      return payrollInstance.addEmployee(accounts[1], 1, {from: accounts[0]});
    }).then( function() {
      return payrollInstance.addEmployee(accounts[1], 1, {from: accounts[0]});
    }).catch( function(error) {
      assert.include(error.toString(),"invalid opcode", "Error!!: Can add same employee");
    });
  });

});

//测试removeEmployee
contract('Payroll_removeEmployee', function(accounts) {

  //测试执行者是否为owner
  it("Test other user want to remove employee", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      return payrollInstance.removeEmployee(accounts[1], {from: accounts[2]});
    }).catch( function(error) {
        assert.include(error.toString(),"revert", "Error!!: other user can remove employee");
    });
  });

  //测试被移除的员工是否存在
  it("Test remove an not exist employee", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      return payrollInstance.removeEmployee(accounts[5], {from: accounts[0]});
    }).catch( function(error) {
        assert.include(error.toString(),"invalid opcode", "Error!!: can remove not exist employee");
    });
  });

  //测试能否成功移除
  it("Test remove an existing employee", function() {
    return Payroll.deployed().then( function(instance) {
      payrollInstance = instance;
      return payrollInstance.addFund({from: accounts[0],value: web3.toWei('3', 'ether')});
    }).then(function(){
      return payrollInstance.addEmployee(accounts[1], 1, {from: accounts[0]});
    }).then(function() {
      return payrollInstance.employees(accounts[1]);
    }).then(function(employee) {
      assert.equal(employee[1].toNumber(), web3.toWei(1, 'ether'), "Error!!: add employee failed!");
    }).then(function() {
      return payrollInstance.removeEmployee(accounts[1]);
    }).then(function() {
      return payrollInstance.employees(accounts[1]);
    }).then(function(employeeTwo) {
      assert.equal(employeeTwo[1].toNumber(), 0, "Error!!: remove employee failed!");
    });
  });

});

/*
测试要考虑的路径覆盖问题：
addEmployee：
1.操作人是否为owner
2.是否被添加的员工已经存在
removeEmployee：
1.执行者是否为owner
2.是否被移除的员工信息存在
*/
