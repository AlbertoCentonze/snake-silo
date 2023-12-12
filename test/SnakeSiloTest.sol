// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console2} from "forge-std/Test.sol";
import {VyperTest} from "vyper/VyperTest.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

interface Silo {
    function deposit(address asset, address receiver, uint256 amount) external returns (uint256, uint256);
}

contract SnakeSiloTest is VyperTest {
    ERC20 weth = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    Silo silo;

    function fork() public {
        vm.createSelectFork(vm.rpcUrl("ethereum_alchemy"));
    }

    function setUp() public {
        fork();
        initDeployer();
        silo = Silo(vyperDeployer.deployContract("Silo", abi.encode(address(weth))));
    }
}
