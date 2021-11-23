// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    AggregatorV3Interface internal priceFeed;
    address owner;
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimumUSD = 50*10**18;
        require(getConversionRate(msg.value) >= minimumUSD,"You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns(uint256){
        return priceFeed.version();
    }

    function getPrice() public view returns(uint256){
      (,int256 answer,,,) = priceFeed.latestRoundData();
      return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 _ETHAmount) public view returns(uint256){
        return (getPrice()*_ETHAmount)/1000000000000000000;
    }

    function getEntranceFee() public view returns (uint256) {
        // mimimumUSD
        uint256 mimimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (mimimumUSD * precision) / price;
//        return (mimimumUSD ,precision , price);
//        return precision;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    function withdraw() payable onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);
        for(uint256 funderIndex=0;funderIndex < funders.length;funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder]=0;
        }
        funders = new address[](0);
    }
}