# Open DeFi Governance Token
an ERC20 governance token with locking/staking features built in

The token has fixed supply - no tokens can be burned, or minted after deployment

# features
Basic ERC20 functionality plus the ability to lock/stake tokens with time-based unlock schedule

## Additional functions
### newTokenLock(uint256 baseTokensLocked_, uint256 unlockEpoch_, uint256 unlockedPerEpoch_) public
Lock `baseTokensLocked_` held by the caller (msg.sender) with `unlockedPerEpoch_` tokens unlocking each `unlockEpoch_`
Afterwards unlockedPerEpoch_ / unlockEpoch_ will unlock each second until all tokens become unlocked.
Emits an {NewTokenLock} event indicating the updated terms of the token lockup.
     
#### Requires

- There must not exist a prevoius lock for this msg.sender. If so, it must be cleared with a call to {clearLock}.
- msg.sender Must have at least a balance of `baseTokensLocked_` to lock
- Must provide non-zero `unlockEpoch_`
- msg.sender Must have at least `unlockedPerEpoch_` tokens to unlock 
- `unlockedPerEpoch_` must be greater than zero

### clearLock() public
Reset the lock state, only if all tokens have been unlocked
     
#### Requires
- msg.sender must not have any tokens locked, currently
    
### balanceUnlocked(address who) public view returns (uint256 amount) 
Returns the amount of tokens that are unlocked i.e. transferrable by the address indicated by `who`
    
### balanceLocked(address who) public view returns (uint256 amount)
Returns the amount of tokens that are locked and not transferrable the address indicated by `who`

### decreaseUnlockAmount(uint256 subtractedValue) public
Reduce the amount of token unlocked each period by `subtractedValue`
Emits an {UpdateTokenLock} event indicating the updated terms of the token lockup.
#### Requires
- msg.sender must have tokens currently locked
- `subtractedValue` is greater than 0
- cannot reduce the unlockedPerEpoch to 0 
#### NOTE 
As a side effect resets the baseTokensLocked and lockTime for msg.sender 


### increaseUnlockTime(uint256 addedValue) public
Increase the duration of the period at which tokens are unlocked by `addedValue`
this will have the net effect of slowing the rate at which tokens are unlocked
Emits an {UpdateTokenLock} event indicating the updated terms of the token lockup.
#### Requires
- msg.sender must have tokens currently locked
- `addedValue` is greater than 0
#### NOTE 
As a side effect resets the baseTokensLocked and lockTime for msg.sender 


### increaseTokensLocked(uint256 addedValue) public 

Increase the number of tokens locked by `addedValue`
i.e. locks up more tokens.
Emits an {UpdateTokenLock} event indicating the updated terms of the token lockup.
#### Requires
- msg.sender must have tokens currently locked
- `addedValue` is greater than zero
- msg.sender must have sufficient unlocked tokens to lock
#### NOTE 
As a side effect resets the baseTokensLocked and lockTime for msg.sender 
