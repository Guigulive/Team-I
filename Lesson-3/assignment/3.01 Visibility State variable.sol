pragma solidity ^0.4.14;

contract Test {
    mapping(uint => uint) public a;
    uint public b;
    
    function test () public {
        a[1] = 2;
    }
}