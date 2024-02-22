const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers")
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs")
const { expect } = require("chai")
const hre = require("hardhat")

describe("WhitelistFactory", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.

  async function whitelistFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners()

    const WhitelistFactory = await ethers.getContractFactory("WhitelistFactory")
    const whitelistFactory = await WhitelistFactory.deploy()

    return { whitelistFactory, owner, otherAccount }
  }

  describe("Access Control", function () {})

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { whitelistFactory, owner } = await loadFixture(whitelistFixture)
      expect(await whitelistFactory.owner()).to.equal(owner.address)
    })

    it("Should fail if the newOwnerShip is not called by the owner", async function () {
      const { whitelistFactory, owner, otherAccount } = await loadFixture(
        whitelistFixture
      )

      await expect(
        whitelistFactory
          .connect(otherAccount)
          .transferOwnership("0xcd3B766CCDd6AE721141F452C550Ca635964ce71")
      ).to.be.revertedWith("You aren't the owner")
    })

    describe("Count", function () {
      it("Should set count in zero", async function () {
        const { whitelistFactory } = await loadFixture(whitelistFixture)
        const count = await whitelistFactory.count.call()
        expect(ethers.toNumber(count)).to.be.a("number")
        expect(count).to.be.equal(0)
      })
    })

    describe("Whitelist", async function () {
      it("Should fail if the start time is smaller than current block time", async function () {
        const startTime = (await time.latest()) - 100
        const endTime = (await time.latest()) - 101
        const { whitelistFactory, owner } = await loadFixture(whitelistFixture)
        expect(
          whitelistFactory.newWhitelist(startTime, endTime, owner.address)
        ).to.be.revertedWith("Start time must be greater than current time")
      })

      it("Should fail if the end time is smaller than start time", async function () {
        const startTime = (await time.latest()) - 100
        const endTime = (await time.latest()) - 101
        const { whitelistFactory, owner } = await loadFixture(whitelistFixture)
        expect(
          whitelistFactory.newWhitelist(startTime, endTime, owner.address)
        ).to.be.revertedWith("Start time must be greater than current time")
      })

      it("Should emit new whitelist created", async function () {
        const metadata =
          "bafybeia4khbew3r2mkflyn7nzlvfzcb3qpfeftz5ivpzfwn77ollj47gqi"
        const startTime = (await time.latest()) + 100
        const endTime = (await time.latest()) + 101
        const { whitelistFactory, owner } = await loadFixture(whitelistFixture)

        expect(
          await whitelistFactory.newWhitelist(
            metadata,
            startTime,
            endTime,
            owner.address
          )
        ).to.emit(
          owner.address,
          "0x0000000000000000000000000000000000000000000000000000000000000001",
          metadata,
          startTime,
          endTime,
          owner.address,
          false
        )
      })
    })
  })
})

/*
 async function deployOneYearLockFixture() {
    const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60
    const ONE_GWEI = 1_000_000_000

    const lockedAmount = ONE_GWEI
    const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners()

    const Lock = await ethers.getContractFactory('Lock')
    const lock = await Lock.deploy(unlockTime, { value: lockedAmount })

    return { lock, unlockTime, lockedAmount, owner, otherAccount }
  }

  describe('Deployment', function () {
    it('Should set the right unlockTime', async function () {
      const { lock, unlockTime } = await loadFixture(deployOneYearLockFixture)

      expect(await lock.unlockTime()).to.equal(unlockTime)
    })

    it('Should set the right owner', async function () {
      const { lock, owner } = await loadFixture(deployOneYearLockFixture)

      expect(await lock.owner()).to.equal(owner.address)
    })

    it('Should receive and store the funds to lock', async function () {
      const { lock, lockedAmount } = await loadFixture(deployOneYearLockFixture)

      expect(await ethers.provider.getBalance(lock.target)).to.equal(lockedAmount)
    })

    it('Should fail if the unlockTime is not in the future', async function () {
      // We don't use the fixture here because we want a different deployment
      const latestTime = await time.latest()
      const Lock = await ethers.getContractFactory('Lock')
      await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith('Unlock time should be in the future')
    })
  })

  describe('Withdrawals', function () {
    describe('Validations', function () {
      it('Should revert with the right error if called too soon', async function () {
        const { lock } = await loadFixture(deployOneYearLockFixture)

        await expect(lock.withdraw()).to.be.revertedWith("You can't withdraw yet")
      })

      it('Should revert with the right error if called from another account', async function () {
        const { lock, unlockTime, otherAccount } = await loadFixture(deployOneYearLockFixture)

        // We can increase the time in Hardhat Network
        await time.increaseTo(unlockTime)

        // We use lock.connect() to send a transaction from another account
        await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith("You aren't the owner")
      })

      it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
        const { lock, unlockTime } = await loadFixture(deployOneYearLockFixture)

        // Transactions are sent using the first signer by default
        await time.increaseTo(unlockTime)

        await expect(lock.withdraw()).not.to.be.reverted
      })
    })

    describe('Events', function () {
      it('Should emit an event on withdrawals', async function () {
        const { lock, unlockTime, lockedAmount } = await loadFixture(deployOneYearLockFixture)

        await time.increaseTo(unlockTime)

        await expect(lock.withdraw()).to.emit(lock, 'Withdrawal').withArgs(lockedAmount, anyValue) // We accept any value as `when` arg
      })
    })

    describe('Transfers', function () {
      it('Should transfer the funds to the owner', async function () {
        const { lock, unlockTime, lockedAmount, owner } = await loadFixture(deployOneYearLockFixture)

        await time.increaseTo(unlockTime)

        await expect(lock.withdraw()).to.changeEtherBalances([owner, lock], [lockedAmount, -lockedAmount])
      })
    })
  })*/
