pragma solidity ^0.4.14;
contract aa {
    address owner;
    function aa() public { // is called by subclasses
        owner = msg.sender;
    }
}
contract aaa is aa {
    uint x;
    function aaa(uint _x) public { x = _x;}
    function aaaF1() internal {
        //if (msg.sender == owner) selfdestrut(owner);
    }
    function aaaF2() public {}
    function aaaF3() external {}
    function aaaF4() private {}
}
contract aaaa is aaa {
    uint y;
    function aaaa(uint _y) aaa (_y*_y) public { y = _y;}
    function child() public {
        aaaF1();
        aaaF2();
        this.aaaF3();
        // aaaF4();
    }
}
contract aaaa2 is aaa(666) {
    uint y;
    function aaaa2(uint _y) public { y = _y;}
    function child() public {
        aaaF1();
        aaaF2();
        this.aaaF3();
        // aaaF4();
    }
}