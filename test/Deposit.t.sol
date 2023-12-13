// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SnakeSiloTest} from "test/SnakeSiloTest.sol";

contract Deposit is SnakeSiloTest {
    address alice = makeAddr("alice");

    function testDeposit() public {
        silo.deposit(address(weth), alice, 100);
    }
}
