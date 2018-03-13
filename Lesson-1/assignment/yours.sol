/*作业请提交在这个目录下*/
Assignment1: make a change to fit general employee;
The original version:
pragma solidity ^0.4.14;	// tell compiler the version of program which is good for 
							//outsourcing interaction 

contract Payroll{	// like Class but contract
	uint salary = 1 ether;	// Tracy's salary
	address Tracy = dsfasdfs235r1345; // the wallet address of Tracy
	uint constant payDuration = 30 days; // the duration to get salary, constant means 
										// payDurantion can't be changed
	uint lastPayday = now;	// the time to get salary
	
	function addFund() payable returns (uint) {	// payable
		return this.balance;	// here this is in address type and return let us can see 
								// the result in decoded output
	}
	
	function calculateRunway() returns(uint) {
		return this.balance / salary;	// to know how many times Tracy can get salary 
										// without adding more money. here, 1/2 = 0.
	}
	
	function hasEnoughFund() returns (bool) {
		return calculateRunway() > 0;	// remember we need to remove this. for saving gas
	}
	
	function getPaid(){
		uint nextPayday = lastPayday + payDuration	// save gas
		if(msg.sender != Tracy){	// if the executor is not Tracy, done.
			revert();
		}
		if(lastPayday + payDuration > now){
			revert();	// Tracy can not get future salary. 
						// Assert(false): compiles to 0xfe, which is an invalid opcode, 
						// using up all remaining gas, and reverting all changes
						// require(false): compiles to 0xfd, which is the REVERT opcode,
						// meaning it will refund the remaining gas. 
		}
		lastPayday = nextPayday;	// here we don't use now() because Tracy can get several
									// months' salary
		Tracy.transfer(salary;)
	}
}

Question: can we modify the code to let it suits to other person and change the salary?

pragma solidity ^0.4.14;

contract Payroll {
    uint constant payDuration = 10 seconds;

    address owner;	
    uint salary;
    address employee;
    uint lastPayday;

    function Payroll() {
        owner = msg.sender;	// construct method for default
    }
    
    function updateEmployee(address e, uint s) {
        require(msg.sender == owner);	// only boss can uodateEmployee
        
        if (employee != 0x0) {	// here we know the address is from employee and check whether
        						// it is null or not
            uint payment = salary * (now - lastPayday) / payDuration;	// sum
            employee.transfer(payment);
        }
        
        employee = e;	// now we really update employee
        salary = s * 1 ether;	// here we set his/her salary
        lastPayday = now;	// update lastPayday
    }
    
    function addFund() payable returns (uint) {
        return this.balance;	// same
    }
    
    function calculateRunway() returns (uint) {
        return this.balance / salary;	// same
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;	// same
    }
    
    function getPaid() {
        require(msg.sender == employee);	// check user id
        
        uint nextPayday = lastPayday + payDuration;	
        assert(nextPayday < now); // if not then stop

        lastPayday = nextPayday;	// update lastPayday before transfer is very important
        employee.transfer(salary);
    }
}
