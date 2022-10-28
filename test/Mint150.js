const { expect, use } = require("chai");
const { ethers } = require("hardhat");
const helpers = require("@nomicfoundation/hardhat-network-helpers");

use(require("chai-as-promised"));

const TARGET_GAS_PRICE = 6_029_700;

const logGasUsage = (currentGasUsage) => {
    const diff = TARGET_GAS_PRICE - currentGasUsage;
    console.log(`           Current gas use:   ${currentGasUsage}`);
    console.log(`           The gas target is: ${TARGET_GAS_PRICE}`);
    if (diff < 0) {
        console.log(
            `           You are \x1b[31m${diff * -1}\x1b[0m above the target`
        );
    }
};

// It's 2021, ETH is $4,600 USD and we have a gas war for a highly sought after NFT.
// The mint is free, but surely it will sell for a big premium...
// You must mint exactly 150 for yourself.
//
//                                 In one transaction.
//
//                     Bonus points if you can beat the gas target...
//
//                       ...which can be done with pure solidity.

// RULES
// - You may not create more accounts/wallets. You may only use the attacker account
// - Because you are only allowed one transaction, you will have to attack from
//   the constructor. We've set this up for you.
// - You may not modify the victim contract

describe("Mint150", async function () {
    let attacker;
    let victimToken;

    let OptimizedAttacker_abi = [
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "victim",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "tokenOffset",
                    "type": "uint256"
                }
            ],
            "stateMutability": "payable",
            "type": "constructor"
        }
    ]

    let OptimizedAttacker_bc = "60408038033d396020513d51631249c58b60e01b3d523060046323b872dd60e01b60965b3d3d843d3d895af19003806100235752523260245260446064836096015b8083523d3d833d3d885af190038085106100415732ff60008060613d393df3"

    beforeEach(async () => {
        await ethers.provider.send("hardhat_reset");

        [owner, attacker] = await ethers.getSigners();
        const VictimToken = await ethers.getContractFactory("contracts/contracts_optimized/OptimizedMint150.sol:NotRareToken");
        victimToken = await VictimToken.deploy();
        await victimToken.deployed();

        // random offset to discourage test fitting
        const numberOfMints = Math.floor(Math.random() * 5) + 1;

        for (let i = 0; i < numberOfMints; i++) {
            let tx = await victimToken.mint();
            await tx.wait();
        }
    });

    describe("Gas target", function () {
        it("The functions MUST meet the expected gas efficiency", async function () {
            // const attackerContract = await ethers.getContractFactory(
            //     "OptimizedAttacker"
            // );
            
            const tokenOffset = await ethers.provider.getStorageAt(victimToken.address, 7); // 7 - totalSupplySlot
            const attackerContract = await ethers.getContractFactory( OptimizedAttacker_abi,OptimizedAttacker_bc );

            const txn = await attackerContract
                .connect(attacker)
                .deploy(victimToken.address,parseInt(tokenOffset,16));

            const receipt = await txn.deployTransaction.wait();
            const gasUsed = receipt.cumulativeGasUsed;

            logGasUsage(gasUsed);

            expect(gasUsed).to.satisfy(function (val) {
                return val <= TARGET_GAS_PRICE;
            });
        });
    });

    describe("Business logic", function () {
        it("The attacker MUST mint 150 NFTs in one transaction", async function () {
            // const attackerContract = await ethers.getContractFactory(
            //     "OptimizedAttacker"
            // );

            const tokenOffset = await ethers.provider.getStorageAt(victimToken.address, 7); // 7 - totalSupplySlot
            const attackerContract = await ethers.getContractFactory( OptimizedAttacker_abi,OptimizedAttacker_bc );

            const txn = await attackerContract
                .connect(attacker)
                .deploy(victimToken.address,parseInt(tokenOffset,16));
        });
    });

    afterEach("hack must succeed", async function () {
        expect(await victimToken.balanceOf(attacker.address)).to.be.equal(150);
        expect(
            await ethers.provider.getTransactionCount(attacker.address)
        ).to.equal(1, "only one transaction allowed");
        expect(victimToken.data);
    });
});
