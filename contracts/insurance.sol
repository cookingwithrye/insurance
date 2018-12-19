pragma solidity ^0.5.1;

contract Insurance {

    uint minimumAmount;

    struct Claim {
        uint amount;
        uint validations; //number of peers that have validated this claim
        mapping (address=>bool) validated;
    }

    mapping (address => Claim) Claims;
    mapping (address => uint) Contributed;

    constructor (uint _minimumAmount) public {
        minimumAmount = _minimumAmount;
    }

    function () external payable {
        Contributed[msg.sender] += msg.value;
    }

    function claim (uint amount) public {
        require(Contributed[msg.sender]>minimumAmount);
        require(amount <= address(this).balance);

        Claims[msg.sender] = Claim(amount, 0);
    }

    function validate (address payable Claimant) public {
        require(Contributed[msg.sender]>minimumAmount);
        //require(Claims[Claimant].validated[msg.sender] == false);

        Claims[Claimant].validated[msg.sender] = true;
        Claims[Claimant].validations += 1;

        if (Claims[Claimant].validations > 0) {
            payout(Claimant);
        }
    }

    function payout(address payable Claimant) internal {
        uint amountToPay = Claims[Claimant].amount;

        Claimant.transfer(amountToPay);

        Claims[Claimant].amount = 0;
        Claims[Claimant].validations = 0;
    }
}