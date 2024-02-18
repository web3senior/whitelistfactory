// Before using this add type:module to package.json file
import Web3 from 'web3'
const web3 = new Web3(`http://127.0.0.1:8545`)


let r = web3.utils.randomHex(1)
console.log(r, typeof 0n)
