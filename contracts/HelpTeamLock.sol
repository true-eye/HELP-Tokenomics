pragma solidity ^0.6.2;

import './SafeMath.sol';
import './Ownable.sol';
import './HelpToken.sol';

contract HelpTeamLock is Ownable {
    using SafeMath for uint256;

    // Constants
    uint256 public constant LOCK_MONTHS = 6; // Month
    uint256 public constant UNLOCK_INTERVAL = 30 days;

    // Variables

    uint256 public lastUnlockTime;
    uint256 public initialLockedAmount;
    bool public locked = false;
    uint256 public totalUnlocked = 0;

    HelpToken public helpToken;

    // Events
    event LockToken(uint256 amount, uint256 snapshot);

    // Constructor

    constructor(HelpToken _helpToken) public {
        helpToken = _helpToken;
    }

    // View Functions

    function nextUnlockTime() public view returns (uint256) {
        if (locked == false) return 0;
        return lastUnlockTime + UNLOCK_INTERVAL;
    }

    function balance() public view returns (uint256) {
        return helpToken.balanceOf(address(this));
    }

    // Methods

    function lock() external onlyOwner {
        require(locked == false, 'HelpTeamLock: already locked');

        uint256 currentBalance = helpToken.balanceOf(address(this));
        require(currentBalance > 0, 'HelpTeamLock: no tokens to lock');

        lastUnlockTime = now;
        initialLockedAmount = currentBalance;
        locked = true;

        emit LockToken(initialLockedAmount, now);
    }

    function unlock(address to) external onlyOwner {
        require(locked == true, 'HelpTeamLock: not yet locked');
        require(to != address(0), 'HelpTeamLock: to address can not be 0');
        require((now - lastUnlockTime) >= UNLOCK_INTERVAL, 'HelpTeamLock: not enough days since last unlock time');

        uint256 lockBalance = helpToken.balanceOf(address(this));
        require(lockBalance > 0, 'HelpTeamLock: no tokens left for unlock');

        uint256 tokensForOneMonth = initialLockedAmount.div(LOCK_MONTHS);
        uint256 tokensToUnlock = lockBalance > tokensForOneMonth ? tokensForOneMonth : lockBalance;

        totalUnlocked = totalUnlocked.add(tokensToUnlock);
        helpToken.transfer(to, tokensToUnlock);
    }
}
