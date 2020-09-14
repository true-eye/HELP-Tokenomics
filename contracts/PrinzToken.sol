pragma solidity ^0.6.2;

// import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
// import 'openzeppelin-solidity/contracts/access/Ownable.sol';
// import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol';
// import 'openzeppelin-solidity/contracts/utils/Address.sol';

import './SafeMath.sol';
import './Ownable.sol';
import './IERC20.sol';
import './Address.sol';

//
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
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
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
    function allowance(address owner, address spender) public virtual override view returns (uint256) {
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
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, 'ERC20: transfer amount exceeds allowance'));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, 'ERC20: decreased allowance below zero'));
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        // require(sender != address(0), "ERC20: transfer from the zero address");
        // require(recipient != address(0), "ERC20: transfer to the zero address");
        // _beforeTokenTransfer(sender, recipient, amount);
        // _balances[sender] = _balances[sender].sub(
        //     amount,
        //     "ERC20: transfer amount exceeds balance"
        // );
        // _balances[recipient] = _balances[recipient].add(amount);
        // emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), 'ERC20: mint to the zero address');

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), 'ERC20: burn from the zero address');

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, 'ERC20: burn amount exceeds balance');
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), 'ERC20: approve from the zero address');
        require(spender != address(0), 'ERC20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

//
interface IUniswapV2Pair {
    function sync() external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract PrinzToken is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 private constant INITIAL_SUPPLY = 777777 * 10**18;

    // Drain Liquidity Pool

    uint256 public lastDrainTime;
    uint256 public totalDrained;
    uint256 public constant DRAIN_RATE = 6; // drain rate per day (6%). Drain happens every day at 3pm UTC time. Actually, no restriction for time
    uint256 public constant DRAIN_REWARD = 4; // drain reward to initializer (4% of 6%)
    uint256 public constant POOL_REWARD = 48; // drain to reward pool (48% of 6%)

    // Transaction Burn
    uint256 public constant TX_BURN = 2; // burn rate per transaction (2%)
    uint256 public constant TX_REWARD = 2; // to reward pool per transaction (2%)
    address public rewardPool;

    // Make a Draw & Claim

    uint256 public constant CLAIM_REWARD = 25; // reward to claimer (5 % of 5% => 0.25%)
    uint256 public constant WINNER_REWARD = 475; // reward to winner  (95% of 5% => 4.75%)
    uint256 public constant MAX_TOP_HOLDERS = 40;
    uint256 public lastRewardTime;

    mapping(uint256 => address) public topHolder;

    uint256 internal totalTopHolders;
    address public lastWinner;
    uint256 public round = 0;
    bool public claimAvailable = false;

    // Pause for allowing tokens to only become transferable at the end of sale
    address public pauser;
    bool public paused;

    bool public drainEnabled;
    bool public feeEnabled;

    // UNISWAP

    // ERC20 internal WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);     // For Main Net
    // ERC20 internal WETH = ERC20(0x0a180A76e4466bF68A7F86fB029BEd3cCcFaAac5);     // For Ropsten Testnet
    ERC20 internal WETH = ERC20(0xd0A1E359811322d97991E03f863a0C30C2cF029C); // For Kovan Testnet
    IUniswapV2Factory public uniswapFactory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    address public uniswapPool;

    uint256 nonce = 0;

    // MODIFIERS

    modifier onlyPauser() {
        require(pauser == _msgSender(), 'PrinzToken: caller is not the pauser.');
        _;
    }

    modifier whenNotPaused() {
        require(!paused, 'PrinzToken: paused');
        _;
    }

    modifier whenClaimAvailable() {
        require(claimAvailable == true, 'PrinzToken: claim not available.');
        _;
    }

    // EVENTS

    event PoolDrained(
        address tender,
        uint256 drainAmount,
        uint256 newTotalSupply,
        uint256 newUniswapPoolSupply,
        uint256 userReward,
        uint256 newPoolReward
    );
    event TopHoldersSnapshotTaken(uint256 totalTopHolders, uint256 snapshot);
    event LogNewRandom(uint256 index);
    event Burn(uint256 tokens);

    constructor() public Ownable() ERC20('PRINZ Token', 'PRINZ') {
        _mint(msg.sender, INITIAL_SUPPLY);
        emit Transfer(address(0x0), msg.sender, INITIAL_SUPPLY);
        setPauser(msg.sender);
        paused = true;
        feeEnabled = false;
        drainEnabled = false;
    }

    function setRewardPool(address _rewardPool) external onlyOwner {
        require(rewardPool == address(0), 'PrinzToken: reward pool already created');
        rewardPool = _rewardPool;
    }

    function setUniswapPool() external onlyOwner {
        require(uniswapPool == address(0), 'PrinzToken: pool already created');
        uniswapPool = uniswapFactory.createPair(address(WETH), address(this));
    }

    // PAUSE

    function setPauser(address newPauser) public onlyOwner {
        require(newPauser != address(0), 'PrinzToken: pauser is the zero address.');
        pauser = newPauser;
    }

    function unpause() external onlyPauser {
        paused = false;
    }

    function enableDrain() external onlyOwner {
        drainEnabled = true;
        lastDrainTime = now;
    }

    function enableFee() external onlyOwner {
        feeEnabled = true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        require(sender != address(0), 'ERC20: transfer from the zero address');
        require(recipient != address(0), 'ERC20: transfer to the zero address');

        _beforeTokenTransfer(sender, recipient, amount);

        if (!feeEnabled) {
            _balances[sender] = _balances[sender].sub(amount, 'ERC20: transfer amount exceeds balance');
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        } else {
            uint256 tokensToBurn = amount.mul(TX_BURN).div(100);
            uint256 tokensToReward = amount.mul(TX_REWARD).div(100);
            uint256 tokensToTransfer = amount.sub(tokensToBurn).sub(tokensToReward);

            _balances[sender] = _balances[sender].sub(amount, 'ERC20: transfer amount exceeds balance');

            _totalSupply = _totalSupply.sub(tokensToBurn, 'ERC20: burn amount exceeds total supply');
            emit Transfer(sender, address(0x0), tokensToBurn);
            emit Burn(tokensToBurn);

            _balances[rewardPool] = _balances[rewardPool].add(tokensToReward);
            emit Transfer(sender, rewardPool, tokensToReward);

            _balances[recipient] = _balances[recipient].add(tokensToTransfer);
            emit Transfer(sender, recipient, tokensToTransfer);
        }
    }

    // TOKEN TRANSFER HOOK

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!paused || from == pauser, 'PrinzToken: token transfer while paused and not pauser role.');
    }

    // DRAINERS

    function getInfoFor(address addr)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        )
    {
        return (
            balanceOf(addr),
            balanceOf(uniswapPool),
            _totalSupply,
            totalDrained,
            getDrainAmount(),
            lastDrainTime,
            // lastRewardTime,
            rewardPool
        );
    }

    // Drain Liquidity Pool

    function drainPool() external {
        require(drainEnabled == true, 'PrinzToken: drain not enabled');
        uint256 drainAmount = getDrainAmount();
        // require(drainAmount >= 1 * 1e18, 'PrinzToken: min drain amount not reached.');

        // Reset last drain time
        lastDrainTime = now;

        uint256 userReward = drainAmount.mul(DRAIN_REWARD).div(100);
        uint256 poolReward = drainAmount.mul(POOL_REWARD).div(100);
        uint256 finalDrain = drainAmount.sub(userReward).sub(poolReward);

        _totalSupply = _totalSupply.sub(finalDrain, 'PrinzToken: burn amount exceeds totalsupply');
        emit Transfer(uniswapPool, address(0x0), finalDrain);
        emit Burn(finalDrain);

        _balances[uniswapPool] = _balances[uniswapPool].sub(drainAmount, 'PrinzToken: drain amount exceeds uniswap liquidity pool');

        totalDrained = totalDrained.add(finalDrain);

        _balances[rewardPool] = _balances[rewardPool].add(poolReward);
        emit Transfer(uniswapPool, rewardPool, poolReward);

        _balances[msg.sender] = _balances[msg.sender].add(userReward);
        emit Transfer(uniswapPool, msg.sender, userReward);

        IUniswapV2Pair(uniswapPool).sync();
        emit PoolDrained(msg.sender, drainAmount, _totalSupply, balanceOf(uniswapPool), userReward, poolReward);
    }

    function getDrainAmount() public view returns (uint256) {
        if (!drainEnabled) return 0;
        uint256 timeBetweenLastDrain = now - lastDrainTime;
        uint256 tokensInUniswapPool = balanceOf(uniswapPool);
        uint256 dayInSeconds = 1 days;
        return (tokensInUniswapPool.mul(DRAIN_RATE).mul(timeBetweenLastDrain)).div(dayInSeconds).div(100);
    }

    // Make a Draw & Claim

    function updateTopHolders(address[] calldata holders) external onlyOwner whenNotPaused {
        require(holders.length > 0, 'PrinzToken: holders length should not be zero');
        totalTopHolders = holders.length < MAX_TOP_HOLDERS ? holders.length : MAX_TOP_HOLDERS;

        for (uint256 i = 0; i < totalTopHolders; i++) {
            topHolder[i] = holders[i];
        }

        for (uint256 i = totalTopHolders; i < MAX_TOP_HOLDERS; i++) {
            topHolder[i] = address(0);
        }

        round = round.add(1);
        claimAvailable = true;

        emit TopHoldersSnapshotTaken(totalTopHolders, now);
    }

    function claimRewards() external whenClaimAvailable whenNotPaused {
        claimAvailable = false;
        require(totalTopHolders > 0, 'PrinzToken: no top holders found');

        nonce += 1;
        uint256 random = uint256(keccak256(abi.encodePacked(nonce, msg.sender, blockhash(block.number - 1))));
        uint256 index = random.mod(totalTopHolders);

        emit LogNewRandom(index);
        address winner = topHolder[index];

        require(winner != address(0), 'winner should not be address(0)');
        require(msg.sender != address(0), 'claimer should not be address(0)');

        uint256 rewardBalance = balanceOf(rewardPool);
        uint256 claimReward = rewardBalance.mul(CLAIM_REWARD).div(10000);
        uint256 winnerReward = rewardBalance.mul(WINNER_REWARD).div(10000);

        _balances[rewardPool] = _balances[rewardPool].sub(claimReward).sub(winnerReward);

        _balances[msg.sender] = _balances[msg.sender].add(claimReward);
        emit Transfer(rewardPool, msg.sender, claimReward);

        _balances[winner] = _balances[winner].add(winnerReward);
        emit Transfer(rewardPool, winner, winnerReward);

        // Reset rewards pool
        lastWinner = winner;
        lastRewardTime = now;
    }
}
