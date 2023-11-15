pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";

contract ReferenceConsumer {
    AggregatorInterface internal ref;

    constructor (address _aggregator) public {
        ref = AggregatorInterface(_aggregator);
    }

    function getLatestAnswer() public view returns (int256) {
        return ref.latestAnswer();
    }
}
