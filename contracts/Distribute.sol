// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

contract OptimizedDistribute {
    address payable immutable contributors_0;
    address payable immutable contributors_1;
    address payable immutable contributors_2;
    address payable immutable contributors_3;
    uint256 immutable createTime;

    constructor(address[4] memory _contributors) payable {
        contributors_0 = payable(_contributors[0]);
        contributors_1 = payable(_contributors[1]);
        contributors_2 = payable(_contributors[2]);
        contributors_3 = payable(_contributors[3]);
        createTime = block.timestamp + 1 weeks;
    }

    // Using Solidity. Gas :: 56940
    // function distribute() external {
    //     uint256 amount = address(this).balance >> 2;
    //     if (block.timestamp > createTime) {
    //         contributors_0.send(amount);
    //         contributors_1.send(amount);
    //         contributors_2.send(amount);
    //         selfdestruct(contributors_3);
    //     }
    //     revert("cannot distribute yet");
    // }

    // Using Assembly. Gas :: 56778
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
