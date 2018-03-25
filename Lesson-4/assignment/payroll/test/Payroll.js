var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function (accounts) {
  const owner = accounts[0]
  const employee = accounts[1]
  const other = accounts[2]
  const salray = 1;

  it("Test call addEmployee() by owner", function () {
    return Payroll.deployed().then(instance => {
      payroll = instance;
      return payroll.addEmployee(employee, salray, { from: owner });
    }).then(() => {
      return payroll.employees(employee);
    }).then(employeeInfo => {
      assert.equal(employeeInfo[1].toNumber(), web3.toWei(salray, 'ether'), "call addEmployee() fail");
    });
  });

  it("Test call addEmployee() twice", function () {
    return Payroll.deployed().then(function (instance) {
      payroll = instance;
      return payroll.addEmployee(employee, salray, { from: owner });
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "invalid opcode", "Should not add duplicated employees");
    });
  });

  it("Test call addEmployee() by other", function () {
    return Payroll.deployed().then(function (instance) {
      payroll = instance;
      return payroll.addEmployee(employee, salray, { from: other });
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception while processing transaction: revert", "Can not call addEmployee() by who is not owner");
    });
  });


  it ("Test call removeEmployee() by owner ", function() {
    return Payroll.deployed().then(function (instance) {
      payroll = instance;
      return payroll.removeEmployee(employee, {from : owner});
    }).then(() => {
      return payroll.employees(employee);
    }).then(employeeInfo => {
      assert.equal(employeeInfo[1].toNumber(),0, "call removeEmployee fail");
    })
  }) ;


  it ("Test remove non-exist employee ", function() {
    return Payroll.deployed().then(function (instance) {
      payroll = instance;
      return payroll.removeEmployee(employee, {from : owner});
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "invalid opcode", "Can not remove non-existent employee");
    })
  }) ;


  it("Test call removeEmployee() by other", function () {
    return Payroll.deployed().then(function (instance) {
      payroll = instance;
      return payroll.addEmployee(employee, salray, { from: owner });
    }).then(() => {
      return payroll.removeEmployee(employee, { from: other});
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception while processing transaction: revert", "Can not call removeEmployee() by who is not owner");
    });
  });

  

});
