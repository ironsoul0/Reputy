// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/utils/math/Math.sol";
import "openzeppelin-contracts/utils/Counters.sol";

import "./SVGGeneration.sol";

error AdminAccessRequired();
error InvalidRatingUpdate();
error NonTransferrableNFT();

contract ReputyApp is ERC721Enumerable {
    struct InitParams {
        string name;
        string fullName;
        string link;
        string tag;
        string symbol;
        string logoURI;
        string description;
        address[] admins;
    }

    struct UserRating {
        address user;
        uint256 rating;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public constant MIN_RATING = 0;
    uint256 public constant MAX_RATING = 100;
    uint256 public constant LEVEL_NUMBER = 5;
    uint256 public constant LEVEL_DIVIDER = MAX_RATING / LEVEL_NUMBER;

    InitParams public appConfig;

    mapping(address => uint256) public userRating;
    address[] public uniqueUsers;

    event RatingSet(
        address indexed user,
        uint256 indexed delta,
        string indexed action
    );
    event RatingAdd(
        address indexed user,
        uint256 indexed delta,
        uint256 newRating,
        string indexed action
    );
    event RatingSub(
        address indexed user,
        uint256 indexed delta,
        uint256 newRating,
        string indexed action
    );

    modifier isAdmin() {
        bool adminFound = false;

        for (uint256 i = 0; i < appConfig.admins.length; i++) {
            if (msg.sender == appConfig.admins[i]) {
                adminFound = true;
            }
        }

        if (!adminFound) {
            revert AdminAccessRequired();
        }

        _;
    }

    constructor(InitParams memory params)
        ERC721(params.fullName, params.symbol)
    {
        appConfig = params;
    }

    function addAdmin(address newAdmin) public isAdmin {
        appConfig.admins.push(newAdmin);
    }

    function setRating(
        address user,
        uint256 newRating,
        string memory action
    ) public isAdmin {
        if (newRating < MIN_RATING || newRating > MAX_RATING) {
            revert InvalidRatingUpdate();
        }
        userRating[user] = newRating;

        _handleRatingUpdate(user);

        emit RatingSet(user, newRating, action);
    }

    function addRating(
        address user,
        uint256 delta,
        string memory action
    ) public isAdmin {
        userRating[user] = Math.min(userRating[user] + delta, MAX_RATING);

        _handleRatingUpdate(user);

        emit RatingAdd(user, delta, userRating[user], action);
    }

    function subRating(
        address user,
        uint256 delta,
        string memory action
    ) public isAdmin {
        delta = Math.min(delta, userRating[user]);
        userRating[user] = Math.max(userRating[user] - delta, MIN_RATING);

        _handleRatingUpdate(user);

        emit RatingSub(user, delta, userRating[user], action);
    }

    function getUsers() external view returns (UserRating[] memory) {
        UserRating[] memory ratings = new UserRating[](uniqueUsers.length);

        for (uint256 i = 0; i < uniqueUsers.length; i++) {
            ratings[i].user = uniqueUsers[i];
            ratings[i].rating = userRating[uniqueUsers[i]];
        }

        return ratings;
    }

    function _getLevelFromRating(uint256 rating)
        private
        pure
        returns (uint256)
    {
        uint256 levelIndex = rating / LEVEL_DIVIDER;
        if (rating == 0 || rating % LEVEL_DIVIDER > 0) {
            levelIndex++;
        }
        return levelIndex;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        _requireMinted(tokenId);

        uint256 rating = userRating[super.ownerOf(tokenId)];
        uint256 level = _getLevelFromRating(rating);

        return SVGGeneration.getTokenURI(appConfig.name, rating, level);
    }

    function _handleRatingUpdate(address user) internal {
        if (super.balanceOf(user) == 0) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(user, newItemId);
            uniqueUsers.push(user);
        }
    }

    function _safeTransfer(
        address,
        address,
        uint256,
        bytes memory
    ) internal pure override {
        revert NonTransferrableNFT();
    }
}
