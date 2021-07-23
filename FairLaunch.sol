// SPDX-License-Identifier: MIT
pragma solidity ^0.5;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "./IUniswap.sol";

contract FairLaunch {
  using SafeMath for uint256;
  //uniswap multichain addresses
  // address public constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
  // address public constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

  //ftm addressses
  address public constant FACTORY = 0x152eE697f2E276fA89E96742e9bB9aB1F2E61bE3;
  address public constant ROUTER = 0xF491e7B69E4244ad4002BC14e878a34207E38c29;

  address public governance;
  address public ytcoin;
  uint256 public totalBought;
  uint256 public totalEthPaid;
  uint256 public totalEthPaidGovernance;
  uint256 public totalAvailable = uint256(5e25).div(2);
  bool public fairLaunchOver = false;

  event Launched(uint coin , uint eth);
  event Bought(uint eth);

	constructor(address _ytcoin) public {
		ytcoin = _ytcoin;
    governance = msg.sender;
	}

  function setLaunchCompleted() public {
    require(msg.sender == governance);
    fairLaunchOver = true;
  }

  function transferProjProfit() public {
    require(msg.sender == governance);
    msg.sender.transfer(totalEthPaidGovernance);
  }

  // insurance against off-by-one errors, eth sent via this
  // function will otherwise be burned
  function donateEth() public payable {
  }

  function addLiquidity() public {
    require(fairLaunchOver, "cont");
    uint _amountA = totalBought;
    uint _amountETH = totalEthPaid;
    IERC20(ytcoin).approve(ROUTER, _amountA);
      IUniswapV2Router(ROUTER).addLiquidityETH.value(_amountETH)(
        ytcoin,
        _amountA,
        _amountA,
        _amountETH,
        address(this),
        block.timestamp
      );
    emit Launched(_amountA, _amountETH);
  }

  function () external payable {
    // 1 YTCOIN = 0.000005 ETH
    // 1 YTCOIN = 0.33 FTM
    uint ethpaid = msg.value.div(2);
    uint ethpaidgov = msg.value.div(2);
    //eth calc, uncomment on eth
    // uint amountBought = ethpaid*(10**6)*5;

    //ftm calc, uncomment on ftm
    uint amountBought = msg.value.mul(3);
    totalBought = totalBought.add(amountBought);
    totalEthPaid = totalEthPaid.add(ethpaid);
    totalEthPaidGovernance = totalEthPaidGovernance.add(ethpaidgov);
    require(amountBought < totalAvailable && !fairLaunchOver, "full");
    IERC20(ytcoin).transfer(msg.sender, amountBought);
    emit Bought(msg.value);
  }

}
