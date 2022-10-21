// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

contract OptimizedDistribute {
    address immutable contributors_0;
    address immutable contributors_1;
    address immutable contributors_2;
    address immutable contributors_3;
    uint256 immutable createTime;

    constructor(address[4] memory _contributors) payable {
        contributors_0 = payable(_contributors[0]);
        contributors_1 = payable(_contributors[1]);
        contributors_2 = payable(_contributors[2]);
        contributors_3 = payable(_contributors[3]);
        createTime = block.timestamp + 1 weeks;
    }

    // Using Solidity. Gas :: 56938
    // function distribute() external {
    //     uint256 amount = address(this).balance >> 2;
    //     require(block.timestamp > createTime, "cannot distribute yet");
    //     payable(contributors_0).send(amount);
    //     payable(contributors_1).send(amount);
    //     payable(contributors_2).send(amount);
    //     selfdestruct(payable(contributors_3));
    // }

    // Using Assembly. Gas :: 56773
    function distribute() external {
        require(block.timestamp > createTime, "cannot distribute yet");
        address temp_0 = contributors_0;
        address temp_1 = contributors_1;
        address temp_2 = contributors_2;
        address temp_3 = contributors_3;
        assembly {
            let amount := shr(2, selfbalance())
            // prettier-ignore
            pop(call(returndatasize(), temp_2, amount,
                            call(returndatasize(), temp_1, amount, returndatasize(), returndatasize(), returndatasize(), returndatasize()),
                            returndatasize(),
                            call(returndatasize(), temp_0, amount, returndatasize(), returndatasize(), returndatasize(), returndatasize()),
                            returndatasize()
                            ))
            selfdestruct(temp_3)
        }
    }
}
