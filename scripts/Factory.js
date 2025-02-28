const { ethers } = require('ethers');
require('dotenv').config();
const { FactoryABI, FactoryAddress } = require('../utils/FactoryConstants');

const provider = new ethers.JsonRpcProvider(process.env.API_KEY);
const signer = new ethers.Wallet(process.env.SECRET_KEY, provider);

const factoryContract = new ethers.Contract(FactoryAddress, FactoryABI, signer);

async function deployPiggyBank(usdc, usdt, dai, salt) {
  try {
    const saltBytes32 = ethers.encodeBytes32String(salt);
    const tx = await factoryContract.deployPiggyBank(
      usdc,
      usdt,
      dai,
      saltBytes32
    );
    console.log('Transaction sent: ', tx.hash);
    const receipt = await tx.wait();
    const event = receipt.events?.find((e) => e.event === 'PiggyBankDeployed');
    console.log('PiggyBank deployed at: ', event?.args.piggyBankAddress);
    return event?.args.piggyBankAddress;
  } catch (error) {
    console.error('Error deploying PiggyBank: ', error);
  }
}

async function getUserPiggyBanks(userAddress) {
  try {
    const piggyBanks = await factoryContract.getUserPiggyBanks(userAddress);
    console.log("User's PiggyBanks: ", piggyBanks);
    return piggyBanks;
  } catch (error) {
    console.error('Error fetching PiggyBanks: ', error);
  }
}

async function getPredictedAddress(salt, usdc, usdt, dai) {
  try {
    const saltBytes32 = ethers.encodeBytes32String(salt);
    const predictedAddress = await factoryContract.getAddress(
      saltBytes32,
      usdc,
      usdt,
      dai
    );
    console.log('Predicted address: ', predictedAddress);
    return predictedAddress;
  } catch (error) {
    console.error('Error predicting address: ', error);
  }
}

async function main() {
  const usdc = '0x2728DD8B45B788e26d12B13Db5A244e5403e7eda';
  const usdt = '0x2728DD8B45B788e26d12B13Db5A244e5403e7eda';
  const dai = '0x2728DD8B45B788e26d12B13Db5A244e5403e7eda';
  const salt = 'customSalt';

  console.log('Predicting address...');
  const predictedAddress = await getPredictedAddress(salt, usdc, usdt, dai);

  console.log('Deploying PiggyBank...');
  const deployedAddress = await deployPiggyBank(usdc, usdt, dai, salt);

  console.log('Fetching user piggy banks...');
  const userPiggyBanks = await getUserPiggyBanks(signer.address);
}

main().catch(console.error);
