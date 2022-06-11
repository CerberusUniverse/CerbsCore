// We import Chai to use its asserting functions here.
const { expect } = require("chai");
const { ethers } = require("hardhat");

// `describe` is a Mocha function that allows you to organize your tests. It's
// not actually needed, but having your tests organized makes debugging them
// easier. All Mocha functions are available in the global scope.

// `describe` receives the name of a section of your test suite, and a callback.
// The callback must define the tests of that section. This callback can't be
// an async function.
describe("Token contract", function () {
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

  // `beforeEach` will run before each test, re-deploying the contract every
  // time. It receives a callback, which can be async.
  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    CDoge = await ethers.getContractFactory("CDoge");
    Berus = await ethers.getContractFactory("Berus");

    cdoge = await CDoge.deploy();
    await cdoge.deployed();
    console.log("CDoge deployed at", cdoge.address);
    
    berus = await Berus.deploy();
    await berus.deployed();
    console.log("Berus deployed at", berus.address);
  });

  // You can nest describe calls to create subsections.
  describe("CDoge check", function () {
    // `it` is another Mocha function. This is the one you use to define your
    // tests. It receives the test name, and a callback function.

    // If the callback function is async, Mocha will `await` it.
    it("burn check", async function () {
        await cdoge.safeMint(addr1.address, 100);
        await cdoge.connect(addr1).burn(ethers.utils.parseEther("1"));
        expect(await cdoge.totalSupply()).to.equal(ethers.utils.parseEther("99"));
    });
  });

  
});