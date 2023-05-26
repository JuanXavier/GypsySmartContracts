// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

interface DataFeed {
    function getData() external returns (uint value);
}

contract DataFeedOK is DataFeed {
    function getData() public pure returns (uint value) {
        return 1;
    }
}

contract EvilFeedContractA {
    function getData() public pure returns (int value) {
        return (-1);
    }
}

contract EvilFeedContractB {
    function getData() public pure returns (address addr) {
        return (address(0x28C565e19D87a092Ab89aa8Fe7601ffbF8878AFf));
    }
}

contract EvilFeedContractC {
    function getData() public pure returns (string memory value) {
        return ("Vamo' lo pibeeeeeeeeeeeeeeee");
    }
}

contract EvilFeedContractD {
    function getData() public pure returns (uint256[] memory) {
        uint256[] memory a;
        a[0] = 2;
        a[1] = 1;
        a[2] = 0;
        return a;
    }
}

contract EvilFeedContractE {
    uint256 count;

    function getData() public {
        count += 1;
    }
}

contract EvilFeedContractF {
    fallback() external {
        // do nothing!
    }
}

contract EvilFeedContractG {}

contract FeedDataGatherer {
    function getDataFromFeed(DataFeed feed) public returns (uint value, bool success) {
        try feed.getData() returns (uint v) {
            return (v, true);
        } catch Error(string memory /*reason*/) {
            // This is executed in case
            // revert was called inside getData
            // and a reason string was provided.
            return (0, false);
        } catch Panic(uint /*errorCode*/) {
            // This is executed in case of a panic,
            // i.e. a serious error like division by zero
            // or overflow. The error code can be used
            // to determine the kind of error.
            return (0, false);
        } catch (bytes memory /*lowLevelData*/) {
            // This is executed in case revert() was used.
            return (0, false);
        }
    }
}
