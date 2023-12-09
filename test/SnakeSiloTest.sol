// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console2} from "forge-std/Test.sol";
import {VyperTest} from "vyper/VyperTest.sol";

interface Silo {
    function deposit(address asset, address receiver, uint256 amount) external returns (uint256, uint256);
}

contract SnakeSiloTest is VyperTest {
    Silo silo;

    function fork() public {
        vm.createSelectFork(vm.rpcUrl("ethereum_alchemy"));
    }

    function setUp() public {
        fork();
        initDeployer();
        silo = Silo(vyperDeployer.deployContract("Silo"));
    }
}
