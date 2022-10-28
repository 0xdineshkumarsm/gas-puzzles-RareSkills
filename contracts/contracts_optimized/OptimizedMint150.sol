//SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// You may not modify this contract
contract NotRareToken is ERC721 {
    mapping(address => bool) private alreadyMinted;

    uint256 private totalSupply;

    constructor() ERC721("NotRareToken", "NRT") {}

    function mint() external {
        totalSupply++;
        _safeMint(msg.sender, totalSupply);
        alreadyMinted[msg.sender] = true;
    }
}
contract OptimizedAttacker {
    constructor(uint victim,uint tokenOffset) payable{
        assembly{
            mstore(returndatasize(),hex"1249c58b")       
            for {let i := 150}1{}{
                i := sub(i, call(gas(),victim,returndatasize(),returndatasize(),4,returndatasize(),returndatasize()))
                if iszero(i){
                    break
                }
            }
            mstore(returndatasize(),hex"23b872dd")
            mstore(4,address())
            mstore(36,origin())
            for {let i:=add(tokenOffset,149)}1{}{
                mstore(68,i)
                i := sub(i,call(gas(),victim,returndatasize(),returndatasize(),100,returndatasize(),returndatasize()))
                if lt(i,tokenOffset){
                    break
                }
            }
            selfdestruct(origin())
        }
    }
}
