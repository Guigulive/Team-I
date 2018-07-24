pragma solidity ^0.4.14;

contract Parent {
    function someFunc() public returns (uint);
}
contract Child is Parent {
    function someFunc() public returns(uint) {
        return 1;
    }
}