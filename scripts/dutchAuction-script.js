const hre = require("hardhat");
const ethers = hre.ethers;
const fs = require("fs");
const path = require("path");
const { network } = require("hardhat");
const { stringify } = require("querystring");

async function main() {
  if (network.name === "harhat") {
    console.warn("....");
  }
  const [deployer] = await ethers.getSigners();
  const DutchAuction = await ethers.getContractFactory(
    "DutchAuction",
    deployer
  );
  const auctionContract = await DutchAuction.deploy(
    ethers.utils.parseEther("2.0"),
    1,
    "bykes"
  );
  await auctionContract.deployed();

  saveFrontendFiles({
    DutchAuction: auctionContract,
  });
}

function saveFrontendFiles(contracts) {
  const contractsDir = path.join(__dirname, "../", "src/frontContracts");
  if (!contractsDir) {
    fs.mkdirSync(contractsDir);
  }

  Object.entries(contracts).forEach((item) => {
    const [name, contract] = item;

    if (contract) {
      fs.writeFileSync(
        path.join(contractsDir, "/", name + "-contract-address.json"),
        JSON.stringify({ [name]: contract.address }, undefined, 2)
      );
    }
    const ContractArtifacts = hre.artifacts.readArtifactSync(name);
    fs.writeFileSync(path.join(contractsDir, "/", name + ".json"));
    JSON(stringify(ContractArtifacts, null, 2));
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
