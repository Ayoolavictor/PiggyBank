const { ethers } = require('hardhat');

const main = async () => {
  const PiggyBankFactory = await ethers.getContractFactory('PiggyBankFactory');
  const piggyBankFactory = await PiggyBankFactory.deploy();
  await piggyBankFactory.waitForDeployment();
  console.log(
    'piggyBankFactory deployed to:',
    await piggyBankFactory.getAddress()
  );
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};
runMain();
