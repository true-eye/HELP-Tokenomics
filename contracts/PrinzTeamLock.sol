pragma solidity ^0.6.2;

import './SafeMath.sol';
import './Ownable.sol';
import './PrinzToken.sol';

contract PrinzTeamLock is Ownable {
    using SafeMath for uint256;

    // Constants
    uint256 public constant LOCK_MONTHS = 6; // Month
    uint256 public constant UNLOCK_INTERVAL = 30 days;

    // Variables

    uint256 public lastUnlockTime;
    uint256 public initialLockedAmount;
    bool public locked = false;
    uint256 public totalUnlocked = 0;

    PrinzToken public prinzToken;

    // Events
    event LockToken(uint256 amount, uint256 snapshot);

    // Constructor

    constructor(PrinzToken _prinzToken) public {
        prinzToken = _prinzToken;
    }

    // View Functions

    function nextUnlockTime() public view returns (uint256) {
        if (locked == false) return 0;
        return lastUnlockTime + UNLOCK_INTERVAL;
    }

    function balance() public view returns (uint256) {
        return prinzToken.balanceOf(address(this));
    }

    // Methods

    function lock() external onlyOwner {
        require(locked == false, 'PrinzTeamLock: already locked');

        uint256 currentBalance = prinzToken.balanceOf(address(this));
        require(currentBalance > 0, 'PrinzTeamLock: no tokens to lock');

        lastUnlockTime = now;
        initialLockedAmount = currentBalance;
        locked = true;

        emit LockToken(initialLockedAmount, now);
    }

    function unlock(address to) external onlyOwner {
        require(locked == true, 'PrinzTeamLock: not yet locked');
        require(to != address(0), 'PrinzTeamLock: to address can not be 0');
        require((now - lastUnlockTime) >= UNLOCK_INTERVAL, 'PrinzTeamLock: not enough days since last unlock time');

        uint256 lockBalance = prinzToken.balanceOf(address(this));
        require(lockBalance > 0, 'PrinzTeamLock: no tokens left for unlock');

        uint256 tokensForOneMonth = initialLockedAmount.div(LOCK_MONTHS);
        uint256 tokensToUnlock = lockBalance > tokensForOneMonth ? tokensForOneMonth : lockBalance;

        totalUnlocked = totalUnlocked.add(tokensToUnlock);
        prinzToken.transfer(to, tokensToUnlock);
    }
}
