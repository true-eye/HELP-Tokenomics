pragma solidity ^0.6.2;

import './SafeMath.sol';
import './Ownable.sol';

contract PrinzTokenPresale is Ownable {
    using SafeMath for uint256;

    struct Candidate {
        uint256 cap_wei;
        uint256 claimed_wei;
    }

    string public constant name = 'Prinz Presale';

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event AddressWhitelisted(address addr, uint256 value);

    uint256 private constant INITIAL_CAP = 77777 * 10**18;
    uint256 private constant MIN_WEI = 0.5 ether;
    uint256 private constant ONLY_LISTED_TIME = 4 hours;
    uint256 private constant TOTAL_TIME = 72 hours;
    uint256 public constant RATE = 1245; // 1 ETH = 1245 PRINZ

    mapping(address => Candidate) private _whitelist;
    mapping(address => uint256) private _balances;

    // address payable public _wallet = 0x80D38136B14E02444d6E3770437061dE041B8348;
    address payable public _wallet;

    uint256 public _tokenBalance;
    uint256 public _weiRaised;

    uint256 private _starttime;

    bool public _locked;
    bool public _closed;

    constructor() public {
        _wallet = msg.sender;
        _locked = true;
        _closed = false;
        _tokenBalance = INITIAL_CAP;
        _whitelist[0x9110EeF60cc95d6B3d5FD0b5c2FD87562caDbAFF].cap_wei = 2 ether;
        _whitelist[0x12BbCaE80e237DbBba3cc4Ef6271B8477d74058d].cap_wei = 2 ether;
    }

    receive() external payable {
        _processBuy(msg.sender, msg.value);
    }

    function unlock() external onlyOwner returns (bool) {
        _locked = false;
        _closed = false;
        _starttime = now;
        return true;
    }

    function lock() external onlyOwner returns (bool) {
        _locked = true;
        return true;
    }

    function whitelistAdd(address beneficiary, uint256 allowedEth) external onlyOwner returns (bool) {
        require(allowedEth.mul(1 ether) >= MIN_WEI, 'thats not enough for whitelist');
        _whitelist[beneficiary].cap_wei = allowedEth.mul(1 ether);
        emit AddressWhitelisted(beneficiary, allowedEth);
        return true;
    }

    function buyToken(address beneficiary, uint256 value) external onlyOwner returns (bool) {
        _processBuy(beneficiary, value);
    }

    function raised() public view returns (uint256) {
        return _weiRaised.div(1 ether);
    }

    function _processBuy(address beneficiary, uint256 weiAmount) private {
        require(_locked == false, 'Presale is locked');
        require(_closed == false, 'Presale is closed');
        require(beneficiary != address(0), 'Not zero address');
        require(beneficiary != owner(), 'Not owner');
        require(weiAmount >= MIN_WEI, 'That isnt enought');
        if (_starttime.add(ONLY_LISTED_TIME) > now) {
            require(_isWhitelisted(beneficiary), "You're not listed, wait a moment");
            require(_getPossibleMaxWei(beneficiary) > 0, 'you cant buy more');
            require(_getPossibleMaxWei(beneficiary) >= weiAmount, 'Thats too much');
        }

        // calculate token amount
        uint256 tokens = _calcTokenAmount(weiAmount);
        require(tokens <= _tokenBalance, 'not enough tokens available');

        // update state
        _weiRaised = _weiRaised.add(weiAmount);
        _tokenBalance = _tokenBalance.sub(tokens);
        _balances[beneficiary] = _balances[beneficiary].add(tokens);
        _whitelist[beneficiary].claimed_wei = _whitelist[beneficiary].claimed_wei.add(weiAmount);

        if (_tokenBalance <= 0) {
            _closed = true;
            _locked = true;
        }

        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);

        if (_starttime.add(TOTAL_TIME) < now) {
            _closed = true;
            _locked = true;
        }

        _forwardFunds();
    }

    function getWei() internal view returns (uint256) {
        return _weiRaised;
    }

    function getRemainingToken() public view returns (uint256) {
        return _tokenBalance;
    }

    function getBalance(address addr) public view returns (uint256) {
        return _balances[addr];
    }

    function getLimit(address addr) public view returns (uint256) {
        return _whitelist[addr].cap_wei;
    }

    function _getPossibleMaxWei(address addr) internal view returns (uint256) {
        return _whitelist[addr].cap_wei.sub(_whitelist[addr].claimed_wei);
    }

    function _calcTokenAmount(uint256 weiAmount) internal pure returns (uint256) {
        return weiAmount.mul(RATE).div(1 ether);
    }

    function _isWhitelisted(address candidate) internal view returns (bool) {
        if (_whitelist[candidate].cap_wei > 0) {
            return true;
        }
        return false;
    }

    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}
