/**
 * 测试前应开启本地链 -> npx hardhat node -> npx hardhat test
 * The local chain should be opened before the test -> npx hardhat node -> npx hardhat test
 */

const { ethers, upgrades } = require("hardhat");
const { expect } = require('chai');

describe("Staking upgradeable contract", () => {
  beforeEach(async () => {
    [this.owner, this._2, this._3] = await ethers.getSigners();
    this.BerusStaking = await ethers.getContractFactory("BerusStakingUpgradeable");
    this.bs = await upgrades.deployProxy(this.BerusStaking, [100, 3, 4, 7, 14],{ 
      kind: 'uups',
      initializer: 'initialize'
    });
    await this.bs.deployed();
    console.log(this.owner.address,this.bs.address);
  });
  it("totalsupply equal to owner's balance", async () => {
    const ownerBalance = await this.bs.balanceOf(this.owner.address);
    expect((await this.bs.totalSupply()).toString()).to.equal((ownerBalance).toString());
  });
  it("transfer to address2 1000000", async () => {
    await this.bs.transfer(this._2.address, 1000000);
    expect((await this.bs.balanceOf(this._2.address)).toString()).to.equal("1000000");
    expect((await this.bs.balanceOf(this.owner.address)).toString()).to.equal("99999999999999000000");
  });
  it("address2 invest 1000000", async () => {
    await this.bs.openInvest();
    await this.bs.transfer(this._2.address, 1000000);
    await this.bs.connect(this._2).approve(this.bs.address, 1000000);
    expect((await this.bs.allowance(this._2.address, this.bs.address)).toString()).to.equal("1000000");
    await this.bs.connect(this._2).Invest(1000000);
    expect((await this.bs.balanceOf(this._2.address)).toString()).to.equal("0");
  });
  it("address2 and address3 both invest 1000000 and close invest then both return 9700000", async () => {
    await this.bs.openInvest();
    await this.bs.transfer(this._2.address, 1000000);
    await this.bs.transfer(this._3.address, 1000000);
    await this.bs.connect(this._2).approve(this.bs.address, 1000000);
    await this.bs.connect(this._3).approve(this.bs.address, 1000000);
    expect((await this.bs.allowance(this._2.address, this.bs.address)).toString()).to.equal("1000000");
    expect((await this.bs.allowance(this._3.address, this.bs.address)).toString()).to.equal("1000000");
    await this.bs.connect(this._2).Invest(1000000);
    await this.bs.connect(this._3).Invest(1000000);
    expect((await this.bs.balanceOf(this._2.address)).toString()).to.equal("0");
    expect((await this.bs.balanceOf(this._3.address)).toString()).to.equal("0");
    await this.bs.closeInvest();
    expect((await this.bs.balanceOf(this._2.address)).toString()).to.equal("970000");
    expect((await this.bs.balanceOf(this._3.address)).toString()).to.equal("970000");
  });

  /**
   * 以下皆为错误测试
   * Below are all error tests
   */

   it("error : Invest closed", async () => {
    await this.bs.transfer(this._2.address, 1000000);
    await this.bs.connect(this._2).approve(this.bs.address, 1000000);
    expect((await this.bs.allowance(this._2.address, this.bs.address)).toString()).to.equal("1000000");
    await this.bs.connect(this._2).Invest(1000000);
  })
  it("error : Does not approve", async () => {
    await this.bs.openInvest();
    await this.bs.transfer(this._2.address, 1000000);
    await this.bs.connect(this._2).Invest(1000000);
  })
  it("error : Amount is not enough", async () => {
    await this.bs.openInvest();
    await this.bs.transfer(this._2.address, 1000000);
    await this.bs.connect(this._2).approve(this.bs.address, 1000000);
    expect((await this.bs.allowance(this._2.address, this.bs.address)).toString()).to.equal("1000000");
    await this.bs.connect(this._2).Invest(2000000);
  })
  it("error : Finalize invest too early", async () => {
    await this.bs.openInvest();
    await this.bs.transfer(this._2.address, 1000000);
    await this.bs.connect(this._2).approve(this.bs.address, 1000000);
    expect((await this.bs.allowance(this._2.address, this.bs.address)).toString()).to.equal("1000000")
    await this.bs.connect(this._2).Invest(1000000);
    expect((await this.bs.balanceOf(this._2.address)).toString()).to.equal("0");
    expect((await this.bs.balanceOf(this.owner.address)).toString()).to.equal("100000000000000000000");
    await new Promise((res, rej) => {
      setTimeout(() => {
        res();
      }, 5000);
    });
    /**
     * Finalize 函数涉及时间戳，若测试中想要有效、精准测试，需要修改合约 Days 为 Minutes 以便节约时间并且测试过程中需要设置定时器。这里没做合约的修改，所以会报错，为了方便测试，可以在 Remix 中快速测试
     * The finalize function involves time stamps. If you want to test effectively and accurately, you need to change the contract days to minutes to save time, and you need to set a timer during the test. There is no contract modification here, so errors will be reported. For the convenience of testing, it can be quickly tested in Remix
     */
    await this.bs.connect(this.owner).finalize();
    expect((await this.bs.balanceOf(this._2.address)).toString()).to.equal("0");
    expect((await this.bs.balanceOf(this.owner.address)).toString()).to.equal("100000000000000000000");
  });
  it("Balance of the owner is insufficient", async () => {
    await this.bs.openInvest();
    await this.bs.transfer(this._2.address, this.bs.balanceOf(this.owner.address));
    await this.bs.connect(this._2).approve(this.bs.address, 1000000);
    expect((await this.bs.allowance(this._2.address, this.bs.address)).toString()).to.equal("1000000");
    await this.bs.connect(this._2).Invest(1000000);
    await this.bs.transfer(this._2.address, 1000000);
    await this.bs.closeInvest();
  });
});
