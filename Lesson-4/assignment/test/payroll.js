var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', (accounts) => {
  let payrollInstance;
  let owner = accounts[0];
  let employee1 = accounts[1];
  let employee2 = accounts[2];
  let fund = 10;

  it("should not add an employee by non-owner.", () => {
    return Payroll.deployed().then((instance) => {
      payrollInstance = instance;
      return payrollInstance.addFund({ value: web3.toWei(fund) });
    }).then(() => {
      return payrollInstance.addEmployee(employee1, 1, { from: employee2 });
    }).catch((err) => {
      console.log('Error adding an employee by non-owner.')
      assert.include(err.message, 'VM Exception');
    });
  });

  it("should add an employee by owner.", () => {
    return Payroll.deployed().then((instance) => {
      payrollInstance = instance;
      return payrollInstance.addFund({ value: web3.toWei(fund) });
    }).then(() => {
      return payrollInstance.addEmployee(employee1, 1, { from: owner });
    }).then(() => {
      return payrollInstance.employees.call(employee1);
    }).then((employeeData) => {
      assert.equal(employeeData[1], web3.toWei(1), "Failed to add the employee.");
    });
  });

  it("should not add same employee twice.", () => {
    return Payroll.deployed().then((instance) => {
      payrollInstance = instance;
      return payrollInstance.addFund({ value: web3.toWei(fund) });
    }).then(() => {
      return payrollInstance.addEmployee(employee1, 1, { from: owner });
    }).catch((err) => {
      console.log('Error adding same employee twice!')
      assert.include(err.message, 'VM Exception');
    });
  });

  it("should remove an existing employee.", () => {
    return Payroll.deployed().then((instance) => {
      payrollInstance = instance;
      return payrollInstance.addFund({ value: web3.toWei(fund) });
    }).then(() => {
      return payrollInstance.addEmployee(employee2, 2, { from: owner });
    }).then(() => {
      return payrollInstance.employees.call(employee2);
    }).then((employeeData) => {
      return payrollInstance.removeEmployee(employee2);
    }).then(() => {
      return payrollInstance.employees.call(employee2);
    }).then((employeeData) => {
      assert.equal(employeeData[0], 0x0, "Failed to remove the employee!");
    });
  });
});

/**
 * 思考：
 * （1）addEmployee
 *  - check if owner only
 *  - check if salary is correct
 *  - check the changes in total salary as new employee added
 *  - what happens if adding the same employee twice
 * （2）removeEmployee
 *  - check if owner only
 *  - check if a given employee exists
 *  - check the changes in total salary after the employee removed
 *  - check if the partial paid performed once the employee removed
 *  - what happens if remove the same employee twice  
 */
