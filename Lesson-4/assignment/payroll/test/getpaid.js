/**
 * Created by lqn on 2018/3/24.
 */
var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function(accounts) {
  var owner = accounts[0];
  var account_one = accounts[1];
  var account_two = accounts[2];
  var account_not_owner = accounts[5];
  var pay_duration = 10; //10 seconds the same defined in Payroll.sol
  var payrollInstance;

  const increaseTime = addSeconds => {
    web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [addSeconds], id: 0
    })
  }

  const forceMine = () => {
    web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_mine",
      params: [], id: 0
    })
  }

  it("Add fund", function () {
    return Payroll.deployed().then(function (instance) {
      payrollInstance = instance;
      return payrollInstance.addFund({from: owner, value: web3.toWei(10, 'ether')});
    }).then(function (res) {
    });
  });

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

  it("Employee can't get paid before pay day.", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      return payrollInstance.getPaid({from: account_one});
    }).then(function(res) {
      throw new Error("Employee can't get paid before pay day.");
    }).catch(function(err) {
      assert.notEqual(err.message, "Employee can't get paid before pay day.", err.message);
    });
  });

  it("Employee can get paid.", function() {
    let before_balance = web3.eth.getBalance(account_one);
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      increaseTime(pay_duration);
      forceMine();
      return payrollInstance.getPaid({from: account_one});
    }).then(function(res) {
      let after_balance = web3.eth.getBalance(account_one);
      let gasUsed = res.receipt.gasUsed;
      let trans = web3.eth.getTransaction(res.tx);
      let gasPrice = trans.gasPrice;
      let tran_balance = before_balance.add(web3.toWei(1,'ether')).sub(after_balance).sub(gasPrice.mul(gasUsed));
      assert.equal(tran_balance, 0, 'Employee get paid failed.');
    });
  });

  it("Non-employee can't get paid.", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      increaseTime(pay_duration+10);
      forceMine();
      return payrollInstance.getPaid({from: account_two});
    }).then(function(res) {
      throw new Error("Non-employee can't get paid.");
    }).catch(function(err) {
      assert.notEqual(err.message, "Non-employee can't get paid.", err.message);
    });
  });

});
