pragma solidity ^0.5.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";
import "./IYTCoin.sol";

contract Breed20 is ERC20, ERC20Detailed, ERC20Burnable, ERC20Mintable {
    using SafeMath for uint256;
    IYTCoin public cryptoCoinytMain;
    address public creatorAddress;
    uint public txCount;
    string public image;
    uint DEFLATION;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 initialSupply,
        string memory _pic,
        address _to,
        address _coinyt,
        uint _deflation
    ) public ERC20Detailed(name, symbol, decimals) {
        require(_deflation <= 500, "defl");
        cryptoCoinytMain = IYTCoin(_coinyt);
        require(isEnoughStakedForCreation() || cryptoCoinytMain.breederFactorCreation() == 0, "stakerr");
        _mint(_to, initialSupply * (10**uint256(decimals)));
        creatorAddress = _to;
        image = _pic;
        DEFLATION = _deflation;
    }

    function isEnoughStakedForCreation() public view returns (bool) {
        uint frozen = cryptoCoinytMain.frozenOf(creatorAddress);
        return frozen >= cryptoCoinytMain.breederFactorCreation();
    }

    function updateImage(string memory _image) public  {
        require(msg.sender == creatorAddress, "a");
        image = _image;
    }

    function isEnoughStakedForTx() public view returns (bool) {
        uint frozen = cryptoCoinytMain.frozenOf(creatorAddress);
        uint factor = cryptoCoinytMain.breederFactor();
        // so 1:1 (normal) frozen to txCount ratio require breederFactor of 1000000;
        // 7 digit precision
        uint frozenScore = frozen.mul(factor).div(1000000);
        return frozenScore >= txCount;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal  {
         require(isEnoughStakedForTx() || cryptoCoinytMain.breederFactor() == 0, "stakerr");
         txCount = txCount + 1;
         // that's the holders tip!
         uint amountAfterTip = amount.mul(950).div(1000);
        _transfer(sender, cryptoCoinytMain.breederTipLover(), amount.mul(50).div(1000) );
        if (DEFLATION != 0) {
        uint deflatedBy = amountAfterTip.mul(DEFLATION).div(1000);
        _transfer(sender, address(0), deflatedBy);
        _transfer(sender, recipient, amountAfterTip.sub(deflatedBy));
        } else {
        _transfer(sender, recipient, amountAfterTip);
        }
    }
}
