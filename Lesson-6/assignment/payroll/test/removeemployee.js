var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function(accounts) {
  var owner = accounts[0];
  var account_one = accounts[1];
  var account_two = accounts[2];
  var account_not_owner = accounts[5];
  var payrollInstance;

  it("Add a new employee", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      return payrollInstance.addEmployee(account_one, 1, {from: owner});
    }).then(function() {
      return payrollInstance.getEmployee.call(account_one, {from: owner});
    }).then(function(res) {
      assert.equal(res[0], account_one, "addresses don't match.");
      assert.equal(res[1].toNumber(), web3.toWei(1, 'ether'), "salary don't match.");
    })
  });

  it("Non-owner can't delete employee", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      return payrollInstance.removeEmployee(account_one, {from: account_not_owner});
    }).then(function() {
      throw new Error('should not deleted by non-owner');
    }).catch(function(err) {
      assert.notEqual(err.message, 'should not deleted by non-owner', err.message);
      assert.include(err.message, 'VM Exception');
    });
  });

  it("Can't delete a non-existed employee", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      return payrollInstance.removeEmployee(account_two, {from: owner});
    }).then(function() {
      throw new Error('Non-existed employee could not be deleted');
    }).catch(function(err) {
      assert.notEqual(err.message, 'Non-existed employee could not be deleted', err.message);
      assert.include(err.message, 'VM Exception');
    })
  });

  it("Delete an employee", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      return payrollInstance.getEmployee.call(account_one, {from: owner});
    }).then(function(res) {
      assert.equal(res[0], account_one, "addresses don't match.")
      return payrollInstance.removeEmployee(account_one, {from: owner});
    }).then(function(res) {
      return payrollInstance.getEmployee.call(account_one, {from: owner});
    }).then(function(res) {
      assert.equal(res[0], 0, "didn't delete successfully..");
    });
  });

  it("Check totalSalay should equal to 0 ethers", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      return payrollInstance.getTotalSalary.call({from: owner});
    }).then(function(res) {
      assert.equal(res.toNumber(), web3.toWei(0, 'ether'), "salary don't match.");
    })
  });

});
