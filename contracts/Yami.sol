// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

// _   _ _     __  ___ _  
//| |_| | |_/ / /\| |_) | Hikari.Finance - Yami Algorithm
//|_| |_|_| \/_/--\_| \_| Coded by nashec using Solidity 0.7.0

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Yami is ERC20 {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    address private owner;
    address private HikariAddress;
    address private HikariAddressLP;
    
    IERC20 private HikariToken;
    IERC20 private HikariTokenLP;
    
    uint256 private varstakingRewards;
    uint256 private varstakingRewardsLP;
    uint256 private _totalHikariStaked;
    uint256 private _totalHikariStakedLP;
    uint256 private InitialSupply = 1000;
    uint256 private lockTime = 15; //19500 - 72H
    uint256 private lockTimeLP = 15; //19500 - 72H
    uint256 private deflationaryCount;
    uint256 private deflationaryBlocks = 39000;
    uint256 private deflationaryDivider = 2;

    mapping(address => Staking) private _stakedBalances;
    mapping(address => Staking) private _stakedBalancesLP;

    struct Staking{
        uint256 lastBlockChecked;
        uint256 lastBlockCheckedLP;
        uint256 rewards;
        uint256 rewardsLP;
        uint256 hikaristaked;
        uint256 hikaristakedLP;
        uint256 stakedAtBlock;
        uint256 stakedAtBlockLP;
    }
    
    constructor() payable ERC20("YAMI", "YAMI") {
        owner = msg.sender;
        _mint(msg.sender, InitialSupply.mul(10 ** 18));
        varstakingRewards = 100000; varstakingRewardsLP = 25000; 
    }
    
    event Staked(address indexed user, uint256 amount, uint256 totalHikariStaked);
    event StakedLP(address indexed user, uint256 amountLP, uint256 totalHikariStakedLP);
    event Withdrawn(address indexed user, uint256 amount);
    event WithdrawnLP(address indexed user, uint256 amountLP);
    event Rewards(address indexed user, uint256 reward);
    event RewardsLP(address indexed user, uint256 rewardLP);
    
    modifier _onlyOwner() {require(msg.sender == owner);_;}

    modifier updateStakingReward(address account) {
        deflationaryCount++;
        if(deflationaryCount >= deflationaryBlocks){
            deflationaryCount = 0;
            varstakingRewards = varstakingRewards / deflationaryDivider;
        }
        if (block.number > _stakedBalances[account].lastBlockChecked) { uint256 rewardBlocks = block.number.sub(_stakedBalances[account].lastBlockChecked);
            if (_stakedBalances[account].hikaristaked > 0) { _stakedBalances[account].rewards = _stakedBalances[account].rewards.add(_stakedBalances[account].hikaristaked.mul(rewardBlocks)/varstakingRewards);}
            _stakedBalances[account].lastBlockChecked = block.number;
            emit Rewards(account, _stakedBalances[account].rewards);                                                     
        }_;
    }
    
    modifier updateStakingRewardLP(address account) {
        deflationaryCount++;
        if(deflationaryCount >= deflationaryBlocks){
            deflationaryCount = 0;
            varstakingRewardsLP = varstakingRewardsLP / deflationaryDivider;
        }
        if (block.number > _stakedBalancesLP[account].lastBlockCheckedLP) { uint256 rewardBlocksLP = block.number.sub(_stakedBalancesLP[account].lastBlockCheckedLP);
            if (_stakedBalancesLP[account].hikaristakedLP > 0) { _stakedBalancesLP[account].rewardsLP = _stakedBalancesLP[account].rewardsLP.add(_stakedBalancesLP[account].hikaristakedLP.mul(rewardBlocksLP)/varstakingRewardsLP);}
            _stakedBalancesLP[account].lastBlockCheckedLP = block.number;
            emit RewardsLP(account, _stakedBalancesLP[account].rewardsLP);                                                     
        }_;
    }
    
    //Sets
    function setHikariAddress(address _hikariaddress) public _onlyOwner returns(uint256) {HikariAddress = _hikariaddress; HikariToken = IERC20(_hikariaddress);}
    function setHikariAddressLP(address _hikariaddressLP) public _onlyOwner returns(uint256) {HikariAddressLP = _hikariaddressLP; HikariTokenLP = IERC20(_hikariaddressLP);}
    function setRewardsVar(uint256 _amount) public _onlyOwner {varstakingRewards = _amount;}
    function setRewardsVarLP(uint256 _amount) public _onlyOwner {varstakingRewardsLP = _amount;}
    function setLockTime(uint256 _amount) public _onlyOwner {lockTime = _amount;}
    function setLockTimeLP(uint256 _amount) public _onlyOwner {lockTimeLP = _amount;}
    function setDeflationaryBlocks(uint256 _amount) public _onlyOwner {deflationaryBlocks = _amount;}
    function setDeflationaryDivider(uint256 _amount) public _onlyOwner {deflationaryDivider = _amount;}
    
    //Gets
    function getBlockNum() public view returns (uint256) {return block.number;}
    function getLastBlockCheckedNum(address _account) public view returns (uint256) {return _stakedBalances[_account].lastBlockChecked;}
    function getLastBlockCheckedNumLP(address _account) public view returns (uint256) {return _stakedBalancesLP[_account].lastBlockCheckedLP;}
    function getAddressStakeAmount(address _account) public view returns (uint256) {return _stakedBalances[_account].hikaristaked;}
    function getAddressStakeAmountLP(address _account) public view returns (uint256) {return _stakedBalancesLP[_account].hikaristakedLP;}
    function getStakedAtBlock(address _account) public view returns (uint256) {return _stakedBalances[_account].stakedAtBlock;}
    function getStakedAtBlockLP(address _account) public view returns (uint256) {return _stakedBalancesLP[_account].stakedAtBlockLP;}
    function getTotalStaked() public view returns (uint256) {return _totalHikariStaked;}
    function getTotalStakedLP() public view returns (uint256) {return _totalHikariStakedLP;}
    function getLockTime() public view returns (uint256) {return lockTime;}
    function getLockTimeLP() public view returns (uint256) {return lockTimeLP;}
    function getVarStakingReward() public view returns (uint256) {return varstakingRewards;}
    function getVarStakingRewardLP() public view returns (uint256) {return varstakingRewardsLP;}
    function getDeflationaryBlocks() public view returns (uint256) {return deflationaryBlocks;}
    function getDeflationaryCount() public view returns (uint256) {return deflationaryCount;}
    function getDeflationaryDivider() public view returns (uint256) {return deflationaryDivider;}

    function updatingStakingReward(address account) public returns(uint256) {
        if (block.number > _stakedBalances[account].lastBlockChecked) {uint256 rewardBlocks = block.number.sub(_stakedBalances[account].lastBlockChecked);
            if (_stakedBalances[account].hikaristaked > 0) {_stakedBalances[account].rewards = _stakedBalances[account].rewards.add(_stakedBalances[account].hikaristaked.mul(rewardBlocks)/ varstakingRewards);}
            _stakedBalances[account].lastBlockChecked = block.number;
            emit Rewards(account, _stakedBalances[account].rewards);} return(_stakedBalances[account].rewards);
    }
    
    function updatingStakingRewardLP(address account) public returns(uint256) {
        if (block.number > _stakedBalancesLP[account].lastBlockCheckedLP) {uint256 rewardBlocksLP = block.number.sub(_stakedBalancesLP[account].lastBlockCheckedLP);
            if (_stakedBalancesLP[account].hikaristakedLP > 0) {_stakedBalancesLP[account].rewardsLP = _stakedBalancesLP[account].rewardsLP.add(_stakedBalancesLP[account].hikaristakedLP.mul(rewardBlocksLP)/ varstakingRewardsLP);}
            _stakedBalancesLP[account].lastBlockCheckedLP = block.number;
            emit RewardsLP(account, _stakedBalancesLP[account].rewardsLP);} return(_stakedBalancesLP[account].rewardsLP);
    }

    function myRewardsBalance(address account) public view returns (uint256) {
        if (block.number > _stakedBalances[account].lastBlockChecked) {uint256 rewardBlocks = block.number.sub(_stakedBalances[account].lastBlockChecked);
            if (_stakedBalances[account].hikaristaked > 0) {return _stakedBalances[account].rewards.add(_stakedBalances[account].hikaristaked.mul(rewardBlocks)/ varstakingRewards);}}
    }
    
    function myRewardsBalanceLP(address account) public view returns (uint256) {
        if (block.number > _stakedBalancesLP[account].lastBlockCheckedLP) {uint256 rewardBlocksLP = block.number.sub(_stakedBalancesLP[account].lastBlockCheckedLP);
            if (_stakedBalancesLP[account].hikaristakedLP > 0) {return _stakedBalancesLP[account].rewardsLP.add(_stakedBalancesLP[account].hikaristakedLP.mul(rewardBlocksLP)/ varstakingRewardsLP);}}
    }
    
    function stake(uint256 amount) public updateStakingReward(msg.sender) {
        _totalHikariStaked = _totalHikariStaked.add(amount);
        _stakedBalances[msg.sender].hikaristaked = _stakedBalances[msg.sender].hikaristaked.add(amount);
        _stakedBalances[msg.sender].stakedAtBlock = block.number; 
        HikariToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount, _totalHikariStaked);
    }
    
    function stakeLP(uint256 amount) public updateStakingRewardLP(msg.sender) {
        _totalHikariStakedLP = _totalHikariStakedLP.add(amount);
        _stakedBalancesLP[msg.sender].hikaristakedLP = _stakedBalancesLP[msg.sender].hikaristakedLP.add(amount);
        _stakedBalancesLP[msg.sender].stakedAtBlockLP = block.number;
        HikariTokenLP.safeTransferFrom(msg.sender, address(this), amount);
        emit StakedLP(msg.sender, amount, _totalHikariStakedLP);
    }
    
    function withdraw(uint256 amount) public updateStakingReward(msg.sender) {
        require((block.number - _stakedBalances[msg.sender].stakedAtBlock) > lockTime, "Locktime not elapsed");
        _totalHikariStaked = _totalHikariStaked.sub(amount);
        _stakedBalances[msg.sender].hikaristaked = _stakedBalances[msg.sender].hikaristaked.sub(amount);
        HikariToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
    
    function withdrawLP(uint256 amount) public updateStakingRewardLP(msg.sender) {
        require((block.number - _stakedBalancesLP[msg.sender].stakedAtBlockLP) > lockTimeLP, "Locktime not elapsed");
        _totalHikariStakedLP = _totalHikariStakedLP.sub(amount);
        _stakedBalancesLP[msg.sender].hikaristakedLP = _stakedBalancesLP[msg.sender].hikaristakedLP.sub(amount);
        HikariTokenLP.safeTransfer(msg.sender, amount);
        emit WithdrawnLP(msg.sender, amount);
    }
    
    function getReward() public updateStakingReward(msg.sender) {
       uint256 reward = _stakedBalances[msg.sender].rewards;
       _stakedBalances[msg.sender].rewards = 0;
       _mint(msg.sender, reward.mul(8) / 10);
       uint256 fundingPoolReward = reward.mul(2) / 10;
       _mint(HikariAddress, fundingPoolReward);
       emit Rewards(msg.sender, reward);
   }
   
    function getRewardLP() public updateStakingRewardLP(msg.sender) {
       uint256 rewardLP = _stakedBalancesLP[msg.sender].rewardsLP;
       _stakedBalancesLP[msg.sender].rewardsLP = 0;
       _mint(msg.sender, rewardLP.mul(8) / 10);
       uint256 fundingPoolRewardLP = rewardLP.mul(2) / 10;
       _mint(HikariAddressLP, fundingPoolRewardLP);
       emit RewardsLP(msg.sender, rewardLP);
   }
   
   //end

}