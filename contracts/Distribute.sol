// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

contract OptimizedDistribute {
    address immutable contributors_0;
    address immutable contributors_1;
    address immutable contributors_2;
    address immutable contributors_3;
    uint256 immutable createTime;

    constructor(address[4] memory _contributors) payable {
        contributors_0 = _contributors[0];
        contributors_1 = _contributors[1];
        contributors_2 = _contributors[2];
        contributors_3 = _contributors[3];
        createTime = block.timestamp + 1 weeks;
    }

    function distribute() external {
        address temp_0 = contributors_0;
        address temp_1 = contributors_1;
        address temp_2 = contributors_2;
        address temp_3 = contributors_3;
        uint256 _createTime = createTime;
        assembly {
            if gt(timestamp(), _createTime) {
                let amount := shr(2, selfbalance())
                // prettier-ignore
                pop(call(gas(), temp_2, amount, returndatasize(), returndatasize(), 
                            call(gas(), temp_1, amount, returndatasize(), returndatasize(), returndatasize(), returndatasize()), 
                            call(gas(), temp_0, amount, returndatasize(), returndatasize(), returndatasize(), returndatasize())))
                selfdestruct(temp_3)
            }
        }
        revert("cannot distribute yet");
    }
}
