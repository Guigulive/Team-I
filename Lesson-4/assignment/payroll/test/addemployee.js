var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function(accounts) {
  var owner = accounts[0]
  var account_one = accounts[1]
  var account_two = accounts[2]
  // var account_three = accounts[3]
  var account_not_owner = accounts[5]
  var payrollInstance

  it("Add a new employee", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance
      return payrollInstance.addEmployee(account_one, 1, {from: owner})
    }).then(function() {
      return payrollInstance.getEmployee.call(account_one, {from: owner})
    }).then(function(res) {
      assert.equal(res[0], account_one, "addresses don't match.")
      assert.equal(res[1].toNumber(), web3.toWei(1, 'ether'), "salary don't match.")
    }).catch(function(err) {
      assert(false, err.message)
    });
  });

  it("Non-owner can't add employee", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance
      return payrollInstance.addEmployee(account_two, 1, {from: account_not_owner})
    }).then(function() {
      throw new Error('should not added by non-owner');
    }).catch(function(err) {
      assert.notEqual(err.message, 'should not added by non-owner', err.message)
    });
  });

  it("Can't add an existed employee", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance
      return payrollInstance.addEmployee(account_one, 1, {from: owner})
    }).then(function() {
      throw new Error('existed employee should not added');
    }).catch(function(err) {
      assert.notEqual(err.message, 'existed employee should not added', err.message)
    })
  });

  it("Add another new employee", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance
      return payrollInstance.addEmployee(account_two, 1, {from: owner})
    }).then(function() {
      return payrollInstance.getEmployee.call(account_two, {from: owner})
    }).then(function(res) {
      assert.equal(res[0], account_two, "addresses don't match.")
      assert.equal(res[1].toNumber(), web3.toWei(1, 'ether'), "salary don't match.")
    }).catch(function(err) {
      assert(false, err.message)
    });
  });

  it("Check totalSalay should equal to 2 ethers", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance
      return payrollInstance.getTotalSalary.call({from: owner})
    }).then(function(res) {
      assert.equal(res.toNumber(), web3.toWei(2, 'ether'), "salary don't match.")
    })
  });

});
