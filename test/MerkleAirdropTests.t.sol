pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BestCoin} from "../src/BestCoin.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTests is Test {
    MerkleAirdrop public merkleAirdrop;
    BestCoin public bestCoin;
    DeployMerkleAirdrop public deployer;

    bytes32 public constant ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public constant AMOUNT = 25 * 1e18;
    uint256 public constant AMOUNT_TO_SEND = AMOUNT * 4;
    bytes32 public constant PROOF_1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public constant PROOF_2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [PROOF_1, PROOF_2];
    address user;
    uint256 userPrivateKey;

    function setUp() public {
        deployer = new DeployMerkleAirdrop();
        (merkleAirdrop, bestCoin) = deployer.run();
        (user, userPrivateKey) = makeAddrAndKey("user");
    }

    function testUsersCanClaim() public {
        uint256 startBalance = bestCoin.balanceOf(user);

        vm.prank(user);
        merkleAirdrop.claim(user, AMOUNT, PROOF);
        uint256 endBalance = bestCoin.balanceOf(user);
        assertEq(endBalance - startBalance, AMOUNT);
    }

    function testCannotClaimTwice() public {
        vm.prank(user);
        merkleAirdrop.claim(user, AMOUNT, PROOF);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__AlreadyClaimed.selector);
        merkleAirdrop.claim(user, AMOUNT, PROOF);
    }

    function testCannotClaimWithInvalidProof() public {
        bytes32[] memory invalidProof = new bytes32[](2);
        invalidProof[0] = bytes32(0x0);
        invalidProof[1] = bytes32(0x0);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__InvalidProof.selector);
        merkleAirdrop.claim(user, AMOUNT, invalidProof);
    }

    function testGetsAirdropToken() public view {
        assertEq(address(merkleAirdrop.getAirdropToken()), address(bestCoin));
    }

    function testGetsMerkleRoot() public view {
        assertEq(merkleAirdrop.getMerkleRoot(), ROOT);
    }
}
