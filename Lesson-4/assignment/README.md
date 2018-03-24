## 硅谷live以太坊智能合约 第四课作业
这里是同学提交作业的目录

### 第四课：课后作业
- 将第三课完成的payroll.sol程序导入truffle工程
- 在test文件夹中，写出对如下两个函数的单元测试：
- function addEmployee(address employeeId, uint salary) onlyOwner
- function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId)
- 思考一下我们如何能覆盖所有的测试路径，包括函数异常的捕捉
- (加分题,选作）
- 写出对以下函数的基于solidity或javascript的单元测试 function getPaid() employeeExist(msg.sender)
- Hint：思考如何对timestamp进行修改，是否需要对所测试的合约进行修改来达到测试的目的？


### 回答
 - 导入Payroll.sol等contract文件后在truffle development环境中调用web3和payrollInstance测试payroll功能正常。

 - addEmployee函数测试路径为：
    - 新添加一个员工
    - 非owner添加员工
    - 添加一个已经存在的员工
    - 再添加一个员工
    - 获取total是否满足 

 - removeEmployee函数测试路径为：
    - 添加一个员工
    - 非owner删除员工
    - 删除不存在的员工
    - 删除存在的员工
    - 获取total是否满足

 - getPaid函数测试路径为：
    - 添加10 ether给contract
    - 添加一个员工
    - 员工在发薪日前不能获得报酬
    - 员工在发薪酬日后可以获得报酬
    - 非员工不能获得报酬

    时间修改使用了助教提示的evm_increaseTime和evm_mine消息。