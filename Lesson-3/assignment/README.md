## 硅谷live以太坊智能合约 第三课作业
这里是同学提交作业的目录

### 第三课：课后作业
- 第一题：完成今天所开发的合约产品化内容，使用Remix调用每一个函数，提交函数调用截图
- 第二题：增加 changePaymentAddress 函数，更改员工的薪水支付地址，思考一下能否使用modifier整合某个功能
- 第三题（加分题）：自学C3 Linearization, 求以下 contract Z 的继承线
- contract O
- contract A is O
- contract B is O
- contract C is O
- contract K1 is A, B
- contract K2 is A, C
- contract Z is K1, K2


### 回答
- 第一题 & 第二题 调用截图顺序为：
  - 1. addEmployee1 （添加第一个员工）
  - 2. addEmployee2 （添加第二个员工）
  - 3. updateEmployee1 （更新第一个员工薪水）
  - 4. calculateRunway （计算可支付薪水次数）
  - 5. removeEmployee1 （删除第一个员工）
  - 6. changePaymentAddress2 （更改第二个员工的收款地址）
  - 7. updateEmployeeNew2 （按照第二个员工新的收款地址更新他的薪资）
  - 8. getPaidNew2 （按照第二个员工新的收款地址获取薪资）

- 第二题：
  - 增加了isEmployee和isNotEmployee modifier用于统一判断特定地址是否属于员工集合

- 第三题：


