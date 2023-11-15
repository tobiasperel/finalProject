pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract Dao is ERC20, Ownable {
    
    mapping (address => bool) public isMember;
    mapping (address => uint256) public balances;
    mapping (uint256 => uint256) public proposals;
    mapping (address => uint256) public blockNumber;
    uint256 private interestRate = 5;
    bool private openDiscuttion = false;

    constructor() ERC20("Patito", "PT") {
        _mint(msg.sender, 1000000000000000000000000);
    }

    function deposit() public payable {
        require(msg.value > 0, "You need to send some ether");
        _mint(msg.sender, msg.value);
        balances[msg.sender] += msg.value*(1+interestRate/100);
        isMember[msg.sender] = true;
        blockNumber[msg.sender] = block.number;
    }
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Not enough DAO tokens");
        _burn(msg.sender, amount);
        
        payable(msg.sender).transfer(amount);
        balances[msg.sender] -= amount;
    }

    function changeInterestRate(uint256 newInterestRate) public {
        require(isMember[msg.sender] == true, "You need to be a member to open a discussion");
        require(newInterestRate > 0, "Interest rate must be greater than 0");
        if (openDiscuttion == false) {
            openDiscuttion = true;
            interestRate = newInterestRate;
        }
        if (proposals[newInterestRate] == 0) {
            proposals[newInterestRate] = 1;
        } else {
            proposals[newInterestRate] += 1;
        }
        if (proposals[newInterestRate] > proposals[interestRate]) {
            interestRate = newInterestRate;
        }
    } 

    function changeInterestRateOwner(uint256 newInterestRate) public onlyOwner {
        interestRate = newInterestRate;
    } 

    function close() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
        //selfdestruct(payable(owner()));
    }


    
}