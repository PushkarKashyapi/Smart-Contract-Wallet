// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;


contract consumer{
    function getbalance()public view returns(uint){
        return  address(this).balance;
    }
    function deposit()public payable{}
}

contract samplewallet{

    address payable  public owner ; 

    mapping(address => uint) public  allowance;
    mapping(address => bool) public  isallowtosend;

    mapping(address => bool) public guardian;
    address payable nextowner;
    mapping(address =>mapping(address => bool))public guardiansvoted;
    uint public nextresetcount ;
    uint public constant confirmationsfromguardianreset = 3;

    constructor(){
        owner  = payable(msg.sender);
    }

    function setguardian(address _guardians , bool _isguardian)public{
        require(msg.sender == owner , "you are not the owner , aborting");
        guardian[_guardians] = _isguardian;

    }

    function  proposenewowner(address payable _newOner)public{
    require(guardiansvoted[_newOner][msg.sender]== false,"you already voted");
    if(nextowner != _newOner){
        nextowner = _newOner;
        nextresetcount = 0;
    }
         
         nextresetcount++;

         if(nextresetcount >= confirmationsfromguardianreset){
        owner = nextowner;
        nextowner = payable(address(0));
     }


    }
    function  setallowance(address _from ,uint _amount )public{
        require(msg.sender == owner , "you are not the owner");
        allowance[_from] =  _amount;
        isallowtosend[_from] =  true;
    }

    function denysending(address _from) public{
        require(msg.sender == owner , "you are not the owner");
        isallowtosend[_from] = false;
    }

     function transfer(address payable _to, uint _amount, bytes memory payload) public returns (bytes memory) {
        require(_amount <= address(this).balance, "Can't send more than the contract owns, aborting.");
        if(msg.sender != owner) {
            require(isallowtosend[msg.sender], "You are not allowed to send any transactions, aborting");
            require(allowance[msg.sender] >= _amount, "You are trying to send more than you are allowed to, aborting");
            allowance[msg.sender] -= _amount;
        }

        (bool success , bytes memory returndata) =_to.call{value :  _amount} (payload);
        require(success , "transaction failed");
        return returndata;

    }
     
    receive() external payable { }
}