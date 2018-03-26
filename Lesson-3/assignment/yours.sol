/*作业请提交在这个目录下*/
第一题：见截图

第二题：
见代码，其中changePaymentAddress函数代码如下：
    function changePaymentAddress(address oldEmployeeId, address newEmployeeId) onlyOwner employeeExist(oldEmployeeId) employeeNotExist(newEmployeeId) public {
        var employee = employees[oldEmployeeId];
        _partialPaid(employee);
        employee.id = newEmployeeId;
        employees[newEmployeeId] = employee;
        delete employees[oldEmployeeId];
    }
其中我新增了modifier employeeNotExist：
    modifier employeeNotExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        _;
    }
该modifer可被用在addEmployee和changePaymentAddress函数中。
同时由于我们用了SafeMath,所以我将代码中出现+，-，*，/的地方都用了add, sub, mul, div代替。

第三题（加分题）：自学C3 Linearization, 求以下 contract Z 的继承线
contract O
contract A is O
contract B is O
contract C is O
contract K1 is A, B
contract K2 is A, C
contract Z is K1, K2

答案：
Following https://en.wikipedia.org/wiki/C3_linearization, C3 superclass linearization of a class is the sum of the class plus a unique merge of the linearizations of its parents and a list of the parents itself. 
注意，在Solidity中，contract Z is K1, K2的意思是合约Z继承合约K2, K1. K2是最先被继承的合约。
L(O)  = [O]
L[A]  = [A] + merge(L[O], [O]) = [A, O]
L[B]  = [B, O]
L[C]  = [C, O]
L[K1] = [K1] + merge(L[B], L[A], [B, A])
      = [K1] + merge([B, O] + [A, O] + [B, A])    //先mergeB,因为ABO中只有B出现的地方都在head
      = [K1, B] + merge([O], [A, O], [A])		  //然后mergeA,因为AO中只有A出现的地方都在head
      = [K1, B, A] + merge([O], [O])
      = [k1, B, A, O]
L[K2] = [K2] + merge(L[C], L[A], [C, A])
	  = [K2] + merge([C, O], [A, O], [C, A])
	  = [K2, C] + merge([O], [A, O], [A])
	  = [K2, C, A, O]
L[Z]  = [Z] + merge(L[K2], L[K1], [K2, K1])
	  = [Z] + merge([K2, C, A, O], [k1, B, A, O], [K2, K1])
	  = [Z, K2] + merge([C, A, O], [K1, B, A, O], [K1])
	  = [Z, K2, C] + merge([A, O], [K1, B, A, O], [K1])
	  = [Z, K2, C, K1] + merge([A, O], [B, A, O])
	  = [Z, K2, C, K1, B] + merge([A, O], [A, O])
	  = [Z, K2, C, K1, B, A, O]
