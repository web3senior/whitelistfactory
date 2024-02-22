# 🛡️Whitelist Factory

---

![Author Badge](assets/badge-author.svg "Aratta")
<a href="//lukso.network">![Lukso Badge](assets/badge-lukso.svg "Lukso")</a>
![Solidity Badge](assets/badge-solidity.svg "Solidity")
<a href="/test">![Test Badge](assets/badge-test.svg "Test")</a>
![HardHat Badge](assets/badge-hardhat.svg "HardHat")
![Prettier Badge](assets/badge-prettier.svg "HardHat")
<a href="//twitter.com/atenyun">![X Badge](assets/badge-x.svg "HardHat")</a>

### Workflow

```
                                     |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
                                     |      START     |
                                     |________________|
                                              ║
                                              ║
                                           Sender
                                              ║
                                              ║
    |¯¯¯¯¯¯¯¯¯|                      |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|                       |¯¯¯¯¯¯¯¯¯¯|
    |   End   |----------NO----------|Is in whitelist?|----------YES----------|   Mint   |
    |_________|                      |________________|                       |__________|
```

## Overview

An allowlist for NFTs is essentially a roster of wallet addresses that are granted the privilege of minting NFTs before a general release of a collection. There are several means of being added to an allowlist, but the primary one is engaging in an NFT project's community.

This smart contract provides a secure and transparent way to manage whitelist access for minting NFTs.

### Advantages

- **Fair and secure NFT distribution:** Prioritize specific users (e.g., early supporters, community members) by granting them exclusive access to mint NFTs before the public sale.

- **Reduce gas fee:** Reduce transaction fees by limiting initial minting to whitelisted addresses.

- **Increase community engagement:** Encourage participation in community activities or social media engagement as criteria for whitelisting.

- **Transparency and immutability:** All whitelist data is stored on the blockchain, ensuring tamper-proof records and open visibility.

### Access Control

- Owner of the contract is not able to do CUD (create, update, and delete)
- Owner of the contract is not able to pause the whitelist

### Motiviation

> On LUKSO, users currently get a free monthly quota of 20.000.000 GAS when creating a Universal Profile through the Universal Profile Browser Extension[1].

### Features

- Whitelist management:
  - Add and remove addresses from the whitelist by the whitelist manager.
  - Make pausaable whitelist
- Minting control:
  - Only whitelisted addresses can mint NFTs during the designated mint period.
  - Set limits on the number of NFTs each whitelisted address can mint.
- Security:
  - Access control ensures only authorized manager can manage the whitelist.
  - Re-entrancy attacks are prevented using standard security practices.

### Getting Started

```
git clone https://github.com/web3senior/whitelistfactory
cd whitelistfactory
npm run test
```

➜ ready for deploying💥

### Deployed Contract

Arbitrum: contract address `0x0` view on explorer `https://`

<!-- Lukso: contract address `0x0` view on explorer `https://` -->


### Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

### ToDo

- Different whitelisting criteria can be implemented (e.g., holding specific tokens, participating in events).

### Reference

<!-- - [1] [Lukso](https://docs.lukso.tech/learn/concepts/#transaction-relay-service:~:text=On%20LUKSO%2C%20users%20currently%20get%20a%20free%20monthly%20quota%20of%2020.000.000%20GAS%20when%20creating%20a%20Universal%20Profile%20through%20the%20Universal%20Profile%20Browser%20Extension.) -->

## License

Distributed under the [MIT](https://choosealicense.com/licenses/mit/) License.

[Amir Rahimi](https://universallink.me/u/atenyun) - Fullstack blockchain developer
