// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/ReputyRegistry.sol";
import "../src/ReputyApp.sol";

contract ReputyScript is Test, Script {
    struct MockUser {
        address user;
        uint256 rating;
    }

    address[] users;
    uint256 constant USER_NUMBER = 10;
    uint256 constant MAX_RATING = 100;

    function setUp() public {
        users = new address[](USER_NUMBER);

        users[0] = address(0x1e2Ce012b27d0c0d3e717e943EF6e62717CEc4ea);
        users[1] = address(0x8593561a4742D799535390BC5C7B992867e50A09);
        users[2] = address(0x51551EBfE65CCcE40DC5C4664E4b2b475B018dBB);
        users[3] = address(0x0482Bb438b284a20E2384A07E3ccc83A968c4fC4);
        users[4] = address(0xF189Cc449626135aC793636D3bC39301a29607ec);
        users[5] = address(0x690B9A9E9aa1C9dB991C7721a92d351Db4FaC990);
        users[6] = address(0x6b333B20fBae3c5c0969dd02176e30802e2fbBdB);
        users[7] = address(0x6887246668a3b87F54DeB3b94Ba47a6f63F32985);
        users[8] = address(0x5E4e65926BA27467555EB562121fac00D24E9dD2);
        users[9] = address(0x50a0387F6355E89dE1C988990C334E0FFC0a19A4);
    }

    function _deployApp(
        ReputyRegistry registry,
        ReputyApp.InitParams memory params
    ) internal {
        ReputyApp app = registry.registerApp(params);

        for (uint256 i = 0; i < users.length; i++) {
            vm.broadcast();

            app.setRating(
                users[i],
                uint256(uint160(users[i])) % MAX_RATING,
                ""
            );
        }

        console.log("Deployed app", params.name, address(app));
    }

    function run() public {
        vm.broadcast();

        ReputyRegistry registry = new ReputyRegistry();
        console.log("Deployed registry:", address(registry));

        address[] memory admins = new address[](USER_NUMBER + 1);
        for (uint256 i = 0; i < USER_NUMBER; i++) {
            admins[i] = users[i];
        }
        admins[USER_NUMBER] = address(msg.sender);

        _deployApp(
            registry,
            ReputyApp.InitParams({
                name: "Uniswap",
                symbol: "UNI",
                logoURI: "N/A",
                description: "Uniswap test project",
                admins: admins
            })
        );

        vm.stopBroadcast();
    }
}
