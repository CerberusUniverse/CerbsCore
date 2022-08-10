// We import Chai to use its asserting functions here.
const { expect } = require("chai");
const { ethers } = require("hardhat");

// `describe` is a Mocha function that allows you to organize your tests. It's
// not actually needed, but having your tests organized makes debugging them
// easier. All Mocha functions are available in the global scope.

// `describe` receives the name of a section of your test suite, and a callback.
// The callback must define the tests of that section. This callback can't be
// an async function.
describe("Vpool contract", function () {
  // Mocha has four functions that let you hook into the test runner's
  // lifecyle. These are: `before`, `beforeEach`, `after`, `afterEach`.

  // They're very useful to setup the environment for tests, and to clean it
  // up after they run.

  // A common pattern is to declare some variables, and assign them in the
  // `before` and `beforeEach` callbacks.

  let owner;
  let addr1;
  let addr2;
  let addrs;

  let maxAnchor = 1000;
  let anchorAddress;
  let tokenAddress;

  // `beforeEach` will run before each test, re-deploying the contract every
  // time. It receives a callback, which can be async.
  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    Vpool = await ethers.getContractFactory("Vpool");
    CDoge = await ethers.getContractFactory("CDoge");
    Berus = await ethers.getContractFactory("Berus");

    cdoge = await CDoge.deploy();
    await cdoge.deployed();
    console.log("CDoge deployed at", cdoge.address);
    
    berus = await Berus.deploy();
    await berus.deployed();
    console.log("Berus deployed at", berus.address);
    
    anchorAddress = cdoge.address;
    tokenAddress = berus.address;
    vpool = await Vpool.deploy(maxAnchor, anchorAddress, tokenAddress);
    await vpool.deployed();
    console.log("Vpool deployed at", vpool.address);
  });

  // You can nest describe calls to create subsections.
  describe("Vpool Math check", function () {
    // `it` is another Mocha function. This is the one you use to define your
    // tests. It receives the test name, and a callback function.

    // If the callback function is async, Mocha will `await` it.
    it("getLevelByTotalToken() math check", async function () {
        for (i=0; i<100; i++) {
            totalToken = Math.floor(Math.random() * Number.MAX_SAFE_INTEGER);
            n = 2 * totalToken / maxAnchor;
            ans_level = Math.floor((Math.sqrt(4 * n + 1) - 1) / 2);

            level = await vpool.getLevelByTotalToken(totalToken);
            // console.log("totaltoken=%s, level=%s", totalToken, ans_level);
            expect(level).to.equal(ans_level);
        }
    });

    it("insertToken() depositAnchor() math check", async function () {
        await berus.safeMint(owner.address, 5_000_000_000_000);
        // unlimited approve of berus _approve(owner, vpool, maxint)
        await berus.approve(vpool.address, ethers.constants.MaxUint256);
        await vpool.insertToken(ethers.utils.parseEther("1500000000000"));

        expect(await vpool.getCurLevel()).to.equal(54772);
        expect(await vpool.getLeftToken()).to.equal(41394000);
        expect(await vpool.getTotalToken()).to.equal(1_500_000_000_000);
        expect(await berus.balanceOf(owner.address)).to.equal(ethers.utils.parseEther("3500000000000"));

        await cdoge.safeMint(owner.address, 1_000_000_000);
        // unlimited approve of doge _approve(owner, vpool, maxint)
        await cdoge.approve(vpool.address, ethers.constants.MaxUint256);
        await vpool.depositAnchor(ethers.utils.parseEther("1756"));
        console.log(await vpool.getCurLevel());
        console.log(await vpool.getLeftToken());
        console.log(await vpool.getTotalToken());
        // console.log(await cdoge.balanceOf(owner.address));
        // console.log(await berus.balanceOf(owner.address));
        expect(await vpool.getCurLevel()).to.equal(54770);
        expect(await vpool.getLeftToken()).to.equal(54770000);
    });

    it("depositAnchor() underflow math check", async function () {
        await berus.safeMint(owner.address, 10000000);
        // unlimited approve of berus _approve(owner, vpool, maxint)
        await berus.approve(vpool.address, ethers.constants.MaxUint256);
        await vpool.insertToken(ethers.utils.parseEther("20000"));
        console.log(await vpool.getCurLevel());
        console.log(await vpool.getLeftToken());
        console.log(await vpool.getTotalToken());

        await cdoge.safeMint(owner.address, 1_000_000_000);
        // unlimited approve of doge _approve(owner, vpool, maxint)
        await cdoge.approve(vpool.address, ethers.constants.MaxUint256);
        await vpool.depositAnchor(ethers.utils.parseEther("1000000"));
        console.log(await vpool.getCurLevel());
        console.log(await vpool.getLeftToken());
        console.log(await vpool.getTotalToken());
        expect(await vpool.getTotalToken()).to.equal(0);

        await vpool.insertToken(ethers.utils.parseEther("5000000"));
        console.log(await vpool.getCurLevel());
        console.log(await vpool.getLeftToken());
        console.log(await vpool.getTotalToken());
    });

    it("withdraw owner check", async function () {
        await berus.safeMint(owner.address, 10000000);
        // unlimited approve of berus _approve(owner, vpool, maxint)
        await berus.approve(vpool.address, ethers.constants.MaxUint256);
        await vpool.insertToken(ethers.utils.parseEther("20000"));
        console.log(await vpool.getCurLevel());
        console.log(await vpool.getLeftToken());
        console.log(await vpool.getTotalToken());

        await cdoge.safeMint(addr1.address, 1_000_000_000);
        // unlimited approve of doge _approve(owner, vpool, maxint)
        await cdoge.connect(addr1).approve(vpool.address, ethers.constants.MaxUint256);
        await vpool.connect(addr1).depositAnchor(ethers.utils.parseEther("100"));
        console.log(await vpool.getCurLevel());
        console.log(await vpool.getLeftToken());
        console.log(await vpool.getTotalToken());

        // await vpool.connect(addr1).withdraw(100); //ERROR!
        await vpool.withdraw(ethers.utils.parseEther("100"));
        expect(await cdoge.balanceOf(vpool.address)).to.equal(0);
        expect(await cdoge.balanceOf(owner.address)).to.equal(ethers.utils.parseEther("100"));
    });

  });

  
});