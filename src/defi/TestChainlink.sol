// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract TestChainlink {
    AggregatorV3Interface internal priceFeed;

    constructor() {
        // ETH / USD
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    }

    function getLatestPrice() public view returns (int256) {
        (uint80 roundID, int256 price, uint256 startedAt, uint256 timeStamp, uint80 answeredInRound) = priceFeed
            .latestRoundData();
        // for ETH / USD price is scaled up by 10 ** 8
        return price / 1e8;
    }
}
