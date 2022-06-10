// libs/Math.sol
// SPDX-License-Identifier: MIT
// https://github.com/barakman/solidity-math-utils/blob/master/project/contracts/IntegralMath.sol
pragma solidity ^0.8.2;

library Math {
    /**
      * @dev Compute the largest integer smaller than or equal to the square root of `n`
    */
    function floorSqrt(uint256 n) internal pure returns (uint256) { unchecked {
        if (n > 0) {
            uint256 x = n / 2 + 1;
            uint256 y = (x + n / x) / 2;
            while (x > y) {
                x = y;
                y = (x + n / x) / 2;
            }
            return x;
        }
        return 0;
    }}
}