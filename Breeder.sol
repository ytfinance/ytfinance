pragma solidity ^0.5.0;

import "./Breed20.sol";
import "./IYTCoin.sol";

contract Breeder {

    address[] public tokenAddress;
    address public coinyt;
    address public devAddress;

    mapping(string => address) public tokenSymbols;

    constructor(
        address  _tok
    ) public {
        coinyt = _tok;
        devAddress = msg.sender;
    }

    function deploy20Contract(
        string calldata name,
        string calldata symbol,
        uint8 decimals,
        uint256 initialSupply,
        string calldata pic,
        uint deflation
    ) external returns (Breed20 coin20Address) {
        require(tokenSymbols[symbol] == address(0), "e");
        Breed20 tok = new Breed20(
            name,
            symbol,
            decimals,
            initialSupply,
            pic,
            msg.sender,
            coinyt,
            deflation
        );
        tokenAddress.push(address(tok));
        tokenSymbols[symbol] = address(tok);
        IYTCoin CoinytToken = IYTCoin(coinyt);
        if (CoinytToken.balanceOf(address(this)) > 5000 * 10**18) {
            // tip dev
            CoinytToken.transfer(devAddress, 5000 * 10**18);
        }
        return tok;
    }

}
