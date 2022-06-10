// contracts/CDoge.sol
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity ^0.8.2;

contract CDoge is Ownable, ERC20 {
    uint constant Precision = 1 ether;
    constructor() ERC20("Cerberus-Real-Peg Dogecoin", "CDOGE") {}

    /**
	 * @dev mint 
	 * 
	 * Params:
	 * - recipient address 
	 * - number uint 
	 */
	function safeMint(address recipient, uint256 number) external onlyOwner {
		require(number > 0, "Cant be 0");

		_mint(recipient, number * Precision);
	}
}