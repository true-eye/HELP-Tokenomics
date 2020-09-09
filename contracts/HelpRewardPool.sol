pragma solidity ^0.6.2;

import 'openzeppelin-solidity/contracts/access/Ownable.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol';
import './provableAPI_0.6.sol';

contract HelpRewardPool is Ownable, usingProvable {
    using SafeMath for uint256;

    // Draw

    uint256 public constant CLAIM_REWARD = 4;
    uint256 public constant WINNER_REWARD = 96;

    uint256 public lastRewardTime;

    IERC20 public rewardToken;

    mapping(address => uint256) public claimedRewards;

    // mapping of top holders that owner update before paying out rewards
    mapping(uint256 => address) public topHolder;

    mapping(bytes32 => address) internal requests;

    // maximum of top topHolder
    uint256 public constant MAX_TOP_HOLDERS = 10;

    uint256 internal totalTopHolders;

    address public lastWinner;

    uint256 public round = 0;

    bool public claimAvailable = false;

    // MODIFIERS

    modifier whenUpdateTopHoldersAvailable() {
        // require()
        _;
    }

    modifier whenClaimAvailable() {
        require(round > 0, 'HelpToken: no snapshot found.');
        require(claimAvailable == true, 'HelpToken: claim not available.');
        _;
    }

    // EVENTS

    event TopHoldersSnapshotTaken(uint256 totalTopHolders, uint256 snapshot);
    event LogNewProvableQuery(string description);
    event LogNewWinnerIndex(string index);

    constructor(IERC20 _rewardToken) public {
        rewardToken = _rewardToken;
    }

    // Rewards

    function updateTopHolders(address[] calldata holders) external onlyOwner whenUpdateTopHoldersAvailable {
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

    function claimRewards() external whenClaimAvailable {
        claimAvailable = false;

        emit LogNewProvableQuery('Provable query was sent, standing by for the answer...');
        bytes32 queryId = provable_query('WolframAlpha', 'random number between 0 and 100');
        requests[queryId] = msg.sender;
    }

    function __callback(bytes32 _queryId, string memory _result) public override {
        if (msg.sender != provable_cbAddress()) revert();

        emit LogNewWinnerIndex(_result);
        uint256 index = uint256(keccak256(abi.encodePacked(_result)));
        index = index.mod(10);

        require(totalTopHolders > index, 'newWinnerIndex exceeds number of top holders');

        address winner = topHolder[index];
        address sender = requests[_queryId];

        uint256 rewardBalance = rewardToken.balanceOf(address(this));
        uint256 claimReward = rewardBalance.mul(CLAIM_REWARD).div(1000);
        uint256 winnerReward = rewardBalance.mul(WINNER_REWARD).div(1000);

        rewardToken.transferFrom(address(this), sender, claimReward);
        rewardToken.transferFrom(address(this), winner, winnerReward);
        claimedRewards[winner] = claimedRewards[winner].add(winnerReward);
        lastWinner = winner;

        // Reset rewards pool
        lastRewardTime = now;
    }
}
