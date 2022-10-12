// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IGrabCoinClub {
    function mintedAt(uint256 tokenId) external view returns (uint256);

    function seriesOf(uint256 tokenId) external view returns (uint256);

    function tokensOfOwner(address owner)
        external
        view
        returns (uint256[] memory);
}

contract Dividends is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20Metadata;

    uint8 constant MULTIPLIER = 10;

    IGrabCoinClub private _nftToken;
    IERC20Metadata private _token;

    mapping(uint256 => uint256) private _lastGrabAt;

    uint256 public constant seriesTotal = 15;
    uint256[seriesTotal] public dividends;

    event UpdatedNFTToken(address indexed _address);
    event UpdatedToken(address indexed _address);
    event GrabbedDividends(address indexed _reciever, uint256 _value);

    constructor(address nftToken, address token) {
        _nftToken = IGrabCoinClub(nftToken);
        _token = IERC20Metadata(token);
        dividends = [
            47, // 4.7
            75, // 7.5
            131, // 13.1
            244, // 24.4
            469, // 46.9
            750, // 75
            1313, // 131.3
            2438, // 243.8
            4688, // 468.8
            7500, // 750
            13125, // 1312.5
            24375, // 2437.5
            46875, // 4687.5
            75000, // 7500
            131250 // 13125
        ];
    }

    function setNFTTokenAddress(address _address) external onlyOwner {
        _nftToken = IGrabCoinClub(_address);
        emit UpdatedNFTToken(_address);
    }

    function setTokenAddress(address _address) external onlyOwner {
        _token = IERC20Metadata(_address);
        emit UpdatedToken(_address);
    }

    function calcDividend(uint256 tokenId) public view returns (uint256) {
        uint256 timestamp1 = _lastGrabAt[tokenId] == 0
            ? _nftToken.mintedAt(tokenId)
            : _lastGrabAt[tokenId];

        return
            (dividends[_nftToken.seriesOf(tokenId)] *
                _diffMonths(timestamp1, block.timestamp) *
                (10**_token.decimals())) / MULTIPLIER;
    }

    function grabDividends() external nonReentrant returns (uint256) {
        uint256 total = 0;
        uint256[] memory tokens = _nftToken.tokensOfOwner(msg.sender);
        for (uint256 i = 0; i < tokens.length; i++) {
            total += calcDividend(tokens[i]);
            _lastGrabAt[tokens[i]] = block.timestamp;
        }

        require(
            total <= _token.balanceOf(address(this)),
            "Insufficient balance"
        );

        _token.safeTransfer(msg.sender, total);
        emit GrabbedDividends(msg.sender, total);

        return total;
    }

    uint256 private constant SECONDS_PER_DAY = 24 * 60 * 60;
    int256 private constant OFFSET19700101 = 2440588;

    function _daysToDate(uint256 _days)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        int256 __days = int256(_days);

        int256 m = __days + 68569 + OFFSET19700101;
        int256 n = (4 * m) / 146097;
        m = m - (146097 * n + 3) / 4;
        int256 _year = (4000 * (m + 1)) / 1461001;
        m = m - (1461 * _year) / 4 + 31;
        int256 _month = (80 * m) / 2447;
        int256 _day = m - (2447 * _month) / 80;
        m = _month / 11;
        _month = _month + 2 - 12 * m;
        _year = 100 * (n - 49) + _year + m;

        year = uint256(_year);
        month = uint256(_month);
        day = uint256(_day);
    }

    struct Date {
        uint256 year;
        uint256 month;
        uint256 day;
    }

    function _diffMonths(uint256 timestamp1, uint256 timestamp2)
        internal
        pure
        returns (uint256)
    {
        Date[2] memory date;
        (date[0].year, date[0].month, ) = _daysToDate(
            timestamp1 / SECONDS_PER_DAY
        );
        (date[1].year, date[1].month, ) = _daysToDate(
            timestamp2 / SECONDS_PER_DAY
        );
        return
            (date[1].year - date[0].year) *
            12 +
            (date[1].month - date[0].month);
    }
}
