// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

// _   _ _     __  ___ _  
//| |_| | |_/ / /\| |_) | Hikari.Finance
//|_| |_|_| \/_/--\_| \_| Coded by nashec using Solidity 0.7.0

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Hikari is ERC20 {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address owner;
    address private hikariFundingAddress;
    address private yamiFundingAddress;

    uint256 private InitialSupply = 40000;

    IERC20 private hikari;
    IERC20 private yami;

    modifier _onlyOwner(){require(msg.sender == owner);_;}
    constructor() payable ERC20("Hikari.Finance", "HIKARI") {owner = msg.sender;  _mint(msg.sender, InitialSupply.mul(10 ** 18));
        hikariFundingAddress = msg.sender; yamiFundingAddress = msg.sender;
    }

    function setHikariAddress(address hikariAddress) public _onlyOwner{hikari = IERC20(hikariAddress);}
    function setYamiAddress(address yamiAddress) public _onlyOwner{yami = IERC20(yamiAddress);}

    function setHikariFundingAddress(address _hikariFundingAddress) public _onlyOwner returns(uint256){hikariFundingAddress = _hikariFundingAddress;}
    function setYamiFundingAddress(address _yamiFundingAddress) public _onlyOwner returns(uint256){yamiFundingAddress = _yamiFundingAddress;}
    
    function getFundingHikariAddress() public view returns (address){hikariFundingAddress;}
    function getFundingYamiAddress() public view returns (address){yamiFundingAddress;}

    function getFundedHikari() public view returns (uint256){hikari.balanceOf(owner);}
    function getFundedYami() public view returns (uint256){yami.balanceOf(owner);}

    function transferFundedHikari(uint256 amount) public {
        hikari.safeTransfer(hikariFundingAddress, amount);
    }

    function transferFundedYami(uint256 amount) public {
        yami.safeTransfer(yamiFundingAddress, amount);
    }
}