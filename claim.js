const { ethers } = require("hardhat");
const config = require("./market_config.json");

async function main() {
    const [_, user] = await ethers.getSigners();
    const pm = await ethers.getContractAt("PredictionMarket", config.pm, user);

    console.log("Claiming winnings...");
    
    try {
        const tx = await pm.claim(0);
        await tx.wait();
        console.log("Winnings Claimed!");
    } catch (e) {
        console.error("Claim Failed:", e.message);
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
