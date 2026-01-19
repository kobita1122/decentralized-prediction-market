# Decentralized Prediction Market

![Solidity](https://img.shields.io/badge/solidity-^0.8.20-blue)
![Type](https://img.shields.io/badge/type-betting-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Overview

**Decentralized Prediction Market** allows users to trade on the outcome of future events. This implementation uses a **Parimutuel** betting model: all bets go into a pool, and the winners split the total pool proportional to their share of the winning side.

## How it Works

1.  **Create**: Admin (or user) creates a market with a deadline.
2.  **Bet**: Users deposit USDC to buy "YES" or "NO" shares.
3.  **Resolve**: An Oracle (or trusted resolver) sets the final outcome.
4.  **Claim**: Winners redeem their shares for their portion of the pool.

## Usage

```bash
# 1. Install
npm install

# 2. Deploy Contracts
npx hardhat run deploy.js --network localhost

# 3. Create a Market ("Will ETH flip BTC?")
node create_market.js

# 4. Place Bets
node bet_yes.js
node bet_no.js

# 5. Resolve Market (Admin only)
node resolve.js

# 6. Claim Winnings
node claim.js
