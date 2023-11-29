pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Dao is ERC20, Ownable {
    address[] public members;
    uint256 public totalMembers;
    mapping (address => bool) public isMember;
    mapping (address => uint256) public balancesUSD;
    mapping (address => uint256) public balancesETH;
    mapping (uint256 => uint256) public proposals;
    mapping (address => uint256) public blockNumber;
    uint256 private interestRate = 5;
    bool private openDiscuttion = false;
    uint256 private ethPrice;

    constructor(uint256 _ethPrice) ERC20("stable", "ST") {
        ethPrice = _ethPrice;
        _mint(msg.sender, 1000000000000000000000000);
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);

    }

    function deposit() public payable {
        require(msg.value > 0, "You need to send some ether");
        
        balancesUSD[msg.sender] += msg.value*ethPrice*(1+interestRate/100);
        if (isMember[msg.sender] == false) {
            totalMembers += 1;
            members.push(msg.sender);
        }
        isMember[msg.sender] = true;
        blockNumber[msg.sender] = block.number;
        _mint(msg.sender, msg.value*ethPrice);
    }
    function withdraw(uint256 amount) public {
        require(balancesUSD[msg.sender] >= amount, "Not enough DAO tokens");
        balancesUSD[msg.sender] -= amount;
        _burn(msg.sender, amount);
        
        payable(msg.sender).transfer(amount/ethPrice);
        
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

    function changeEthPrice (uint256 newEthPrice) public onlyOwner {
        ethPrice = newEthPrice;
    }

    // Uniswap router address for mainnet
address private constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

IUniswapV2Router02 public uniswapRouter;

    function swapEthForDai(uint ethAmount) public onlyOwner payable {
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI address on mainnet

        uniswapRouter.swapExactETHForTokens{ value: msg.value }(
            ethAmount,
            path,
            msg.sender,
            block.timestamp
        );
    }
    
    function sellEth() public {
        require(isMember[msg.sender] == true, "You need to be a member to open a discussion");
        uint membersToErrase = 0;
        address aux = address(0);
        for (uint256 i = 0; i < totalMembers ; i++) {
            if (balancesETH[members[i]] * ethPrice < balancesUSD[members[i]]){
                swapEthForDai(balancesETH[members[i]]);
                balancesUSD[members[i]] -= balancesETH[members[i]] * ethPrice;
                balancesETH[members[i]] = 0;
                isMember[members[i]] = false;
                membersToErrase += 1;
                aux = members[i] ;
                members[i] =  members[totalMembers - 1] ;
                members[totalMembers - 1] = aux;
                members.pop();
            }
        }
        totalMembers -= membersToErrase;
    }

    function close() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
        //selfdestruct(payable(owner()));
    }


    
}