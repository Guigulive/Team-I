/*作业请提交在这个目录下*/
var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function(accounts) {
  let instance;
  let owner = accounts[0];
  let employeeId = accounts[1];
  let payDuration = 10;
  let initialDeposit = 100;

  function getBalance(address) {
    return web3.eth.getBalance(address).toNumber();
  }

  beforeEach(async () => {
    instance = await Payroll.new({from: owner});
  })


  describe("addEmployee", () => {
    it("Test onlyOwner", async () => {
      try {
        await instance.addEmployee(employeeId, 1, {from: employeeId});
      } catch (e) {
        assert.notEqual(employeeId, owner, `Not owner.`);
      }
    });

    it("Check correct address and salary", async () => {
      await instance.addEmployee(employeeId, 1, {from: owner});
      const employee = await instance.employees(employeeId);
      assert.equal(employee[0], employeeId, "address correct");
      assert.equal(web3.fromWei(employee[1].toNumber(), "ether"), 1, "salary correct");
    });
  });
  
  describe("removeEmployee", () => {
    it("Test onlyOwner", async () => {
      await instance.addEmployee(employeeId, 1, {from: owner});
      try {
        await instance.removeEmployee(employeeId, {from: employeeId});
      } catch (e) {
        assert.notEqual(employeeId, owner, `Not owner.`);
      }
    });

    it("Check correct removal", async () => {
      await instance.addEmployee(employeeId, 1, {from: owner});
      let employee = await instance.employees(employeeId);
      assert.equal(employee[0], employeeId, "address correct");
      await instance.removeEmployee(employeeId, {from: owner});
      employee = await instance.employees(employeeId);
      assert.equal(employee[0], 0, "salary correct");
    });
  });
    
});

思考：
addEmployee
1. 是否是owner操作
2. 地址工资是否设置正确
3. 添加一个已经存在的人
removeEmployee
1. 是否是owner操作
2. 地址工资是否设置正确
3. 删除一个不存在的人
4. 部分工资是否成功发送到之前的地址