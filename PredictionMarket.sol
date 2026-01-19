// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PredictionMarket is Ownable {
    IERC20 public bettingToken;

    enum Outcome { PENDING, YES, NO }

    struct Market {
        string question;
        uint256 endTime;
        uint256 totalYes;
        uint256 totalNo;
        Outcome outcome;
        bool resolved;
    }

    // Market ID -> User -> Outcome -> Amount
    mapping(uint256 => mapping(address => mapping(Outcome => uint256))) public bets;
    Market[] public markets;

    event MarketCreated(uint256 indexed id, string question, uint256 endTime);
    event BetPlaced(uint256 indexed id, address indexed user, Outcome direction, uint256 amount);
    event MarketResolved(uint256 indexed id, Outcome outcome);
    event WinningsClaimed(uint256 indexed id, address indexed user, uint256 amount);

    constructor(address _token) Ownable(msg.sender) {
        bettingToken = IERC20(_token);
    }

    function createMarket(string memory _question, uint256 _duration) external onlyOwner {
        markets.push(Market({
            question: _question,
            endTime: block.timestamp + _duration,
            totalYes: 0,
            totalNo: 0,
            outcome: Outcome.PENDING,
            resolved: false
        }));
        emit MarketCreated(markets.length - 1, _question, block.timestamp + _duration);
    }

    function bet(uint256 _marketId, Outcome _direction, uint256 _amount) external {
        require(_marketId < markets.length, "Invalid market");
        require(markets[_marketId].outcome == Outcome.PENDING, "Market ended");
        require(block.timestamp < markets[_marketId].endTime, "Time expired");
        require(_direction == Outcome.YES || _direction == Outcome.NO, "Invalid outcome");
        require(_amount > 0, "Amount 0");

        bettingToken.transferFrom(msg.sender, address(this), _amount);

        if (_direction == Outcome.YES) {
            markets[_marketId].totalYes += _amount;
        } else {
            markets[_marketId].totalNo += _amount;
        }

        bets[_marketId][msg.sender][_direction] += _amount;
        emit BetPlaced(_marketId, msg.sender, _direction, _amount);
    }

    function resolve(uint256 _marketId, Outcome _outcome) external onlyOwner {
        require(!markets[_marketId].resolved, "Already resolved");
        require(block.timestamp >= markets[_marketId].endTime, "Not ended yet");
        require(_outcome != Outcome.PENDING, "Must be YES or NO");

        markets[_marketId].outcome = _outcome;
        markets[_marketId].resolved = true;
        
        emit MarketResolved(_marketId, _outcome);
    }

    function claim(uint256 _marketId) external {
        Market memory m = markets[_marketId];
        require(m.resolved, "Not resolved");
        
        uint256 userBet = bets[_marketId][msg.sender][m.outcome];
        require(userBet > 0, "No winning bet");

        uint256 totalPool = m.totalYes + m.totalNo;
        uint256 winningPool = (m.outcome == Outcome.YES) ? m.totalYes : m.totalNo;

        // Reward = (UserBet / WinningPool) * TotalPool
        uint256 reward = (userBet * totalPool) / winningPool;

        // Zero out bet to prevent re-entrancy/double claim
        bets[_marketId][msg.sender][m.outcome] = 0;
        
        bettingToken.transfer(msg.sender, reward);
        emit WinningsClaimed(_marketId, msg.sender, reward);
    }
}
