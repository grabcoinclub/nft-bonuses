// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
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
    IGrabCoinClub private _nftToken;
    IERC20Metadata private _token;

    mapping(uint256 => uint256) private _lastGrabAt;

    uint256 public constant seriesTotal = 15;
    uint256[seriesTotal] public dividends;

    constructor(address nftToken, address token) {
        _nftToken = IGrabCoinClub(nftToken);
        _token = IERC20Metadata(token);
        dividends = [
            47,
            75,
            131,
            244,
            469,
            750,
            1313,
            2438,
            4688,
            7500,
            13125,
            24375,
            46875,
            75000,
            131250
        ];
    }

    function setNFTTokenAddress(address _address) external onlyOwner {
        _nftToken = IGrabCoinClub(_address);
    }

    function setTokenAddress(address _address) external onlyOwner {
        _token = IERC20Metadata(_address);
    }

    function calcDividend(uint256 tokenId) public view returns (uint256) {
        uint256 timestamp1 = _lastGrabAt[tokenId] == 0
            ? _nftToken.mintedAt(tokenId)
            : _lastGrabAt[tokenId];

        return
            dividends[_nftToken.seriesOf(tokenId)] *
            _diffMonths(timestamp1, block.timestamp);
    }

    function grabDividends() external nonReentrant returns (uint256) {
        uint256 total;
        uint256[] memory tokens = _nftToken.tokensOfOwner(msg.sender);
        for (uint256 i = 0; i < tokens.length; i++) {
            total += calcDividend(tokens[i]);
            _lastGrabAt[tokens[i]] = block.timestamp;
        }

        _token.transfer(msg.sender, (total * 10**_token.decimals()) / 10);
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
