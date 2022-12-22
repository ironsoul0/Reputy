// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/ReputyApp.sol";
import "../src/SVGGeneration.sol";

contract ReputyTest is Test {
    function testRatingUpdate() public {
        address admin = address(0x1);
        address bob = address(0x2);

        address[] memory admins = new address[](1);
        admins[0] = admin;

        ReputyApp.InitParams memory params = ReputyApp.InitParams({
            name: "Uniswap",
            symbol: "UNI",
            logoURI: "N/A",
            description: "Uniswap test project",
            admins: admins
        });

        ReputyApp app = new ReputyApp(params);

        vm.startPrank(admin);
        app.setRating(bob, 10, "Test action");
        assertEq(app.balanceOf(bob), 1);
        assertEq(app.userRating(bob), 10);

        console.log(app.tokenURI(1));

        vm.stopPrank();
    }
}
