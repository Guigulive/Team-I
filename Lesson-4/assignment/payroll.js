var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function (accounts) {

    it("...addEmployee successfully.", function () {
        return Payroll.deployed().then(function (instance) {
            homeworkInstance = instance;
        }).then(function () {
            return homeworkInstance.addFund({
                value: web3.toWei(99999999999999999999999999999)
            });
        }).then(function () {
            return homeworkInstance.addEmployee(accounts[0], 2);
        }).then(function () {
            return homeworkInstance.employees.call(accounts[0]);
        }).then(function (employee) {
            assert.equal(employee[0].valueOf(), web3.toWei(2), "WTF.");
        });
    });

    it("...removeEmployee successfully.", function () {
        return Payroll.deployed().then(function (instance) {
            homeworkInstance = instance;
        }).then(function () {
            return homeworkInstance.addEmployee(accounts[1], 3);
        }).then(function () {
            return homeworkInstance.removeEmployee(accounts[1]);
        }).then(function () {
            return homeworkInstance.employees.call(accounts[1]);
        }).then(function (employee) {
            assert.equal(employee[0].valueOf(), 0x0, "fail")
        })
    });

});