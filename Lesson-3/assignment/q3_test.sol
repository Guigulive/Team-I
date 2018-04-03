pragma solidity ^0.4.18;

contract O {
  uint public a = 1;
}

contract A is O {
  uint public a = 3;
}

contract B is O {
  uint public a = 4;
}

contract C is O {
  uint public a = 5;
}

contract K1 is A,B {
  uint public a = 6;
}

contract K2 is A,C {
  uint public a = 7;
}

contract Z is K1,K2 {

}

