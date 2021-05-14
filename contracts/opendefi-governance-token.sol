// References:
//https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol
//https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol

/**
Copyright 2021 Open DeFi DAO


Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * */
 
pragma solidity ^0.8.0;



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

contract OpenDeFiGovernance is ERC20 {

    string private constant ERROR_ADD_OVERFLOW = "MATH_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH_DIV_ZERO";

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b, ERROR_MUL_OVERFLOW);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }

    constructor(string memory name_, string memory symbol_, uint256 amount_, address deployer_) ERC20(name_, symbol_){
        _mint(deployer_, amount_);
    }
    
    string private constant ERROR_INSUFFICIENT_UNLOCKED = "Not enough unlocked tokens for transfer";
    string private constant ERROR_LOCK_EXISTS = "Token lock already exists";
    string private constant ERROR_INSUFFICIENT_TOKENS = "Not enough tokens to lock";
    string private constant ERROR_EPOCH_ZERO = "Unlock interval must be greater than zero";
    string private constant ERROR_BAD_UNLOCK_AMOUNT = "Unlock amount must be between 1 and the locked amount";
    string private constant ERROR_CLEARING_LOCK = "Cannot clear lock while tokens are locked";
    string private constant ERROR_BAD_NEW_UNLOCK_AMT = "New unlock amount must be lower than current";
    string private constant ERROR_BAD_NEW_UNLOCK_TIME = "New unlock time must be greater than current";
    string private constant ERROR_BAD_NEW_LOCKED_AMT = "New amount locked must be greater than current";
    string private constant ERROR_NO_LOCKED_TOKENS = "No tokens are locked, create new lock first";
    
    
    mapping (address => uint256) public lockTime; //the time tokens were locked
    mapping (address => uint256) public unlockEpoch; //the time interval at which tokens unlock
    mapping (address => uint256) public unlockedPerEpoch; // the number of tokens unlocked per unlockEpoch
    mapping (address => uint256) public baseTokensLocked; // the number of tokens locked up by HOLDER
    /**
     * @dev Emitted when the token lock changes including initiating a new lock or updating an existing lock to be more strict
     * `tokenHolder` is the address the lock pertains to
     *  `amountLocked` is the amount of tokens locked 
     *  `time` is the (initial) time at which tokens were locked
     *  `unlockPeriod` is the time interval at which tokens become unlockedPerPeriod
     *  `unlockedPerPeriod` is the amount of token unlocked earch unlockPeriod
     */
    event  NewTokenLock(address tokenHolder, uint256 amountLocked, uint256 time, uint256 unlockPeriod, uint256 unlockedPerPeriod);
    
    /**
     * @dev require that at least `amount` tokens are unlocked before transfer is possible
     *  also permit if minting tokens (coming from 0x0)
     *
    */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal  virtual override {
            require(from == address(0x0) || amount <= balanceUnlocked(from), ERROR_INSUFFICIENT_UNLOCKED);
    }
    
    /**
     * @dev Lock `baseTokensLocked_` held by the caller with `unlockedPerEpoch_` tokens unlocking each `unlockEpoch_`
     *
     *
     * Emits an {NewTokenLock} event indicating the updated terms of the token lockup.
     *
     * Requirements:
     *
     * - Must not be a prevoius lock for this address. If so, it must be cleared with a call to {clearLock}.
     * - Must have at least a balance of `baseTokensLocked_` to lock
     * - Must provide non-zero `unlockEpoch_`
     * - Must have at least `unlockedPerEpoch_` tokens to unlock 
     *  - `unlockedPerEpoch_` must be greater than zero
     */
    
    function newTokenLock(uint256 baseTokensLocked_, uint256 unlockEpoch_, uint256 unlockedPerEpoch_) public {
        require(balanceLocked(msg.sender) == 0, ERROR_LOCK_EXISTS);
        require(balanceOf(msg.sender) >= baseTokensLocked_, ERROR_INSUFFICIENT_TOKENS); 
        require(unlockEpoch_ > 0, ERROR_EPOCH_ZERO);
        require(unlockedPerEpoch_ <= baseTokensLocked_ &&  unlockedPerEpoch_ > 0, ERROR_BAD_UNLOCK_AMOUNT);
        lockTime[msg.sender] = block.timestamp;
        unlockEpoch[msg.sender] = unlockEpoch_;
        unlockedPerEpoch[msg.sender] = unlockedPerEpoch_;
        baseTokensLocked[msg.sender] = baseTokensLocked_;
        emit NewTokenLock(msg.sender, baseTokensLocked[msg.sender], lockTime[msg.sender], unlockEpoch[msg.sender], unlockedPerEpoch[msg.sender]);
    }
    
    /**
     * @dev Reset the lock state
     *
     * Requirements:
     *
     * - Must not have any tokens locked, currently
     */
    function clearLock() public {
        require(balanceLocked(msg.sender) == 0, ERROR_CLEARING_LOCK);
        lockTime[msg.sender] = 0;
        unlockEpoch[msg.sender] = 0;
        unlockedPerEpoch[msg.sender] = 0;
        baseTokensLocked[msg.sender] = 0;
    }
    
    /**
     * @dev Returns the amount of tokens that are unlocked i.e. transferrable by `who`
     *
     */
    function balanceUnlocked(address who) public view returns (uint256 amount) {
        
        return sub(balanceOf(who), balanceLocked(who));
        
    }
    /**
     * @dev Returns the amount of tokens that are locked and not transferrable by `who`
     *
     */
    function balanceLocked(address who) public view returns (uint256 amount){
        if(baseTokensLocked[who] == 0){
            return 0;
        }
        //unlockedOverTime = unlockedPerEpoch[who]*((block.timestamp - lockTime[who]) / unlockEpoch[who])
        uint256 unlockedOverTime = mul(unlockedPerEpoch[who] , (div( sub(block.timestamp, lockTime[who]) , unlockEpoch[who])));
        if(baseTokensLocked[who] <  unlockedOverTime){
            return 0;
        }
        return sub(baseTokensLocked[who], unlockedOverTime);
        
    }
    /**
     * @dev Reduce the amount of token unlocked each period to `newAmount`
     * 
     * Emits an {NewTokenLock} event indicating the updated terms of the token lockup.
     * 
     * Requires: 
     *  - There Must be tokens currently locked
     *  - `newAmount` is less than the current amount
     *
     */
    function reduceUnlockAmountTo(uint256 newAmount) public {
        require(newAmount < unlockedPerEpoch[msg.sender], ERROR_BAD_NEW_UNLOCK_AMT);
        require(balanceLocked(msg.sender) > 0, ERROR_NO_LOCKED_TOKENS);
    
        unlockedPerEpoch[msg.sender] = newAmount;
        emit NewTokenLock(msg.sender, baseTokensLocked[msg.sender], lockTime[msg.sender], unlockEpoch[msg.sender], unlockedPerEpoch[msg.sender]);
    
    }
    /**
     * @dev Increase the duration of the period at which tokens are unlocked to `newTime`
     * this will have the net effect of slowing the rate at which tokens are unlocked
     * 
     * Emits an {NewTokenLock} event indicating the updated terms of the token lockup.
     * 
     * Requires: 
     *  - There Must be tokens currently locked
     *  - `newTime` is greater than the current period
     *
     */
    function increaseUnlockTime(uint256 newTime) public {
        require(newTime > unlockEpoch[msg.sender], ERROR_BAD_NEW_UNLOCK_TIME);
        require(balanceLocked(msg.sender) > 0, ERROR_NO_LOCKED_TOKENS);
    
        unlockEpoch[msg.sender] = newTime;
        emit NewTokenLock(msg.sender, baseTokensLocked[msg.sender], lockTime[msg.sender], unlockEpoch[msg.sender], unlockedPerEpoch[msg.sender]);
    
    }
    /**
     * @dev Increase the number of tokens locked by `newAmount`
     * i.e. locks up more tokens.
     * 
     *      
     * Emits an {NewTokenLock} event indicating the updated terms of the token lockup.
     * 
     * Requires: 
     *  - There Must be tokens currently locked
     *  - `newAmount` is greater than zero
     *  - there Must be sufficient unlocked tokens to lock
     * 
     * Note: Will reset the countdown to the next token unlock epoch
     *
     */
    function increaseTokensLocked(uint256 newAmount) public {
        require(newAmount > 0, ERROR_BAD_NEW_LOCKED_AMT);
        require(balanceLocked(msg.sender) > 0, ERROR_NO_LOCKED_TOKENS);
        require(newAmount <= balanceUnlocked(msg.sender), ERROR_INSUFFICIENT_TOKENS);
        //baseTokensLocked[msg.sender] = add(newAmount, baseTokensLocked[msg.sender]);
        baseTokensLocked[msg.sender] = add(newAmount, balanceLocked(msg.sender));
        lockTime[msg.sender] = block.timestamp;
        emit NewTokenLock(msg.sender, baseTokensLocked[msg.sender], lockTime[msg.sender], unlockEpoch[msg.sender], unlockedPerEpoch[msg.sender]);
    }
}

