// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./ReputyApp.sol";

contract ReputyRegistry {
    ReputyApp[] public apps;

    event NewAppRegistered(address indexed appAddress, string indexed appName);

    function registerApp(ReputyApp.InitParams memory params)
        external
        returns (ReputyApp)
    {
        ReputyApp app = new ReputyApp(params);
        apps.push(app);

        emit NewAppRegistered(address(app), params.name);

        return app;
    }
}
