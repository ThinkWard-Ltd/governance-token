# governance-token
an ERC20 governance token with locking/staking features built in

# features
Basic ERC20 functionality plus the ability to lock/stake tokens with time-based unlock schedule

## Additional functions
### newTokenLock(uint256 baseTokensLocked_, uint256 unlockEpoch_, uint256 unlockedPerEpoch_) public
Lock `baseTokensLocked_` held by the caller (msg.sender) with `unlockedPerEpoch_` tokens unlocking each `unlockEpoch_`
Emits an {NewTokenLock} event indicating the updated terms of the token lockup.
     
#### Requires

- There must not exist a prevoius lock for this msg.sender. If so, it must be cleared with a call to {clearLock}.
- msg.sender Must have at least a balance of `baseTokensLocked_` to lock
- Must provide non-zero `unlockEpoch_`
- msg.sender Must have at least `unlockedPerEpoch_` tokens to unlock 
- `unlockedPerEpoch_` must be greater than zero

### clearLock() public
Reset the lock state
     
#### Requires
- msg.sender must not have any tokens locked, currently
    
### balanceUnlocked(address who) public view returns (uint256 amount) 
Returns the amount of tokens that are unlocked i.e. transferrable by the address indicated by `who`
    
### balanceLocked(address who) public view returns (uint256 amount)
Returns the amount of tokens that are locked and not transferrable the address indicated by `who`

### reduceUnlockAmountTo(uint256 newAmount) public
Reduce the amount of token unlocked each period to `newAmount`
Emits an {NewTokenLock} event indicating the updated terms of the token lockup.
#### Requires
- msg.sender Must have tokens currently locked
- `newAmount` is less than the current amount
 
### increaseUnlockTime(uint256 newTime) public
increase the duration of the period at which tokens are unlocked to `newTime`
this will have the net effect of slowing the rate at which tokens are unlocked
Emits an {NewTokenLock} event indicating the updated terms of the token lockup.
#### Requires 
- msg.sender Must have tokens currently locked
- `newTime` is greater than the current period


### increaseTokensLocked(uint256 newAmount) public 
Increase the number of tokens msg.sender has locked by `newAmount`
i.e. locks up more tokens by msg.sender
Emits an {NewTokenLock} event indicating the updated terms of the token lockup.
#### Requires 
- msg.sender Must be tokens currently locked
- `newAmount` is greater than zero
- msg.sender Must have sufficient unlocked tokens to lock

Note: Will reset the countdown to the next token unlock epoch
    

