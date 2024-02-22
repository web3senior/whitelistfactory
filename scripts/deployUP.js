const hre = require("hardhat")
const { ethers } = require("hardhat")
const dotenv = require("dotenv")
const LSP0ABI = require("@lukso/lsp-smart-contracts/artifacts/LSP0ERC725Account.json")

// load env vars
dotenv.config()

async function main() {
  // setup provider
  const provider = new ethers.JsonRpcProvider(
    "https://rpc.testnet.lukso.gateway.fm"
  )
  // setup signer (the browser extension controller)
  const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider)
  console.log("Deploying contracts with EOA: ", signer.address)

  // load the associated UP
  const UP = new ethers.Contract(process.env.UP_ADDR, LSP0ABI.abi, signer)

  /**
   * Custom LSP7 Token
   */
  const WhitelistFactoryBytecode =
    hre.artifacts.readArtifactSync("WhitelistFactory").bytecode

  // get the address of the contract that will be created
  const WhitelistFactoryAddress = await UP.connect(signer)
    .getFunction("execute")
    .staticCall(1, ethers.ZeroAddress, 0, WhitelistFactoryBytecode)

  // deploy CustomLSP7 as the UP (signed by the browser extension controller)
  const tx1 = await UP.connect(signer).getFunction("execute")(
    1,
    ethers.ZeroAddress,
    0,
    WhitelistFactoryBytecode
  )

  await tx1.wait()

  console.log("Custom token address: ", WhitelistFactoryAddress)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
