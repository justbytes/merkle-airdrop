pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BestCoin} from "../src/BestCoin.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Script} from "forge-std/Script.sol";

contract DeployMerkleAirdrop is Script {
    MerkleAirdrop public merkleAirdrop;
    BestCoin public bestCoin;
    bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_amountToTransfer = 4 * 25 * 1e18;

    function run() external returns (MerkleAirdrop, BestCoin) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BestCoin) {
        vm.startBroadcast();
        bestCoin = new BestCoin();
        merkleAirdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(bestCoin)));
        bestCoin.mint(bestCoin.owner(), s_amountToTransfer);
        bestCoin.transfer(address(merkleAirdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (merkleAirdrop, bestCoin);
    }
}
