// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/utils/Base64.sol";
import "openzeppelin-contracts/utils/Strings.sol";
import "forge-std/console.sol";

library SVGGeneration {
    string constant PREFIX_NAME = "Reputy";

    function _genSquare(
        uint256 x,
        uint256 y,
        uint256 levelReq,
        uint256 level
    ) internal pure returns (string memory) {
        string memory fillColor = "#FFFFFF";
        if (level >= levelReq) {
            fillColor = "#6943FF";
        }

        return
            string(
                abi.encodePacked(
                    "<rect x='",
                    Strings.toString(x),
                    "'  y='",
                    Strings.toString(y),
                    "' width='113' height='92' fill='",
                    fillColor,
                    "'/>"
                )
            );
    }

    function _getImageURI(
        string memory appName,
        uint256 rating,
        uint256 level
    ) internal pure returns (string memory) {
        string
            memory svg = "<svg width='640' height='565' viewBox='0 0 640 565' fill='none' xmlns='http://www.w3.org/2000/svg'>"
            "<style>.base { fill: #6943FF; font-family: sans-serif; font-size: 70px; font-weight: bold; } .main { font-size: 75px; } .white { fill: #FFFFFF; }</style>"
            "<rect width='640' height='565' fill='#BDB7FF'/>";

        svg = string(
            abi.encodePacked(
                svg,
                _genSquare(465, 164, 5, level),
                _genSquare(370, 236, 4, level),
                _genSquare(279, 295, 3, level),
                _genSquare(189, 364, 2, level),
                _genSquare(97, 433, 1, level)
            )
        );

        svg = string(
            abi.encodePacked(
                svg,
                "<text x='30' y='100' class='base main'>",
                appName,
                "</text>"
            )
        );

        svg = string(
            abi.encodePacked(
                svg,
                "<text x='30' y='180' class='base white'>Rating: ",
                Strings.toString(rating),
                "</text>"
            )
        );

        svg = string(
            abi.encodePacked(
                svg,
                "<text x='30' y='260' class='base white'>Level: ",
                Strings.toString(level),
                "</text></svg>"
            )
        );

        return svg;
    }

    function getTokenURI(
        string memory appName,
        uint256 rating,
        uint256 level
    ) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                PREFIX_NAME,
                                " ",
                                appName,
                                '", "description":"", "attributes":"", "image":"',
                                _getImageURI(appName, rating, level),
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
