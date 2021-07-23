pragma solidity ^0.5.0;

interface IYTCoin {
	function frozenOf(address _user) external view returns (uint256);
	function totalFrozen() external view returns (uint256);
	function breederFactor() external view returns (uint256);
	function breederFactorCreation() external view returns (uint256);
	function breederTipLover() external view returns (address);
	function transfer(address _to, uint256 _tokens) external returns (bool);
	function balanceOf(address _user) external view returns (uint256);
}
