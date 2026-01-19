const { ethers } = require("hardhat");
const config = require("./market_config.json");

async function main() {
    const [admin] = await ethers.getSigners();
    const pm = await ethers.getContractAt("PredictionMarket", config.pm, admin);

    // Simulate time passing
    // await ethers.provider.send("evm_increaseTime", [4000]);
    // await ethers.provider.send("evm_mine");

    console.log("Resolving Market 0 to YES...");
    
    const YES = 1;
    const tx = await pm.resolve(0, YES);
    await tx.wait();

    console.log("Market Resolved!");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
