//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract AucEngine{
        address public owner;
        uint constant Duration = 2 days;
        uint constant Fee = 10;
        event AuctionCreated( uint startingPrice, uint index, string item, uint duration);
        event AuctionEnded(uint index, uint currentPrice, address sender);

        struct Auction{
            address payable seller;
            uint startAt;
            uint endAt;
            uint startingPrice;
            uint finalPrice;
            uint discountRate;
            string item;
            bool stopped;
        }
        Auction auction;

        Auction[] public auctions;

        constructor(){
            owner = msg.sender;
        }

        

        function newAuction(uint _startingPrice, uint _discountRate, string calldata _item, uint _duration) external{
            uint duration = _duration == 0 ? Duration : _duration;

            require(_startingPrice >= _discountRate * duration, "incorrect price!");

            Auction memory newAuction = Auction(
              {
                    seller: payable(msg.sender),
                    startingPrice: _startingPrice,
                    finalPrice: _startingPrice,
                    discountRate: _discountRate,
                    startAt: block.timestamp,
                    endAt: duration+ block.timestamp,
                    item: _item,
                    stopped: false
              }
            );
             auctions.push(newAuction);
              emit AuctionCreated(_startingPrice, auctions.length-1, _item, duration);
        }

        function paymentFor(uint index) public view returns(uint){
            Auction memory currentAuction = auctions[index];
            require(!currentAuction.stopped, "stopped!");
            uint elapsed = block.timestamp - currentAuction.startAt;
            uint discount = currentAuction.discountRate - elapsed;
            return currentAuction.startingPrice - discount;
        }

        function buy(uint index) external payable{
             Auction storage currentAuction = auctions[index];
             require(!currentAuction.stopped, "stopped!");
             require(block.timestamp<currentAuction.endAt, "end!");
             uint currentPrice = paymentFor(index);
             require(msg.value >= currentPrice, "not enought!");
             payable(msg.sender).transfer(currentPrice);
             uint refund =msg.value - currentPrice;
             if(refund > 0){
                 payable(msg.sender).transfer(refund);
             }
             uint sellerMoney = currentPrice-((currentPrice * 10)/100);
             uint ownerMoney = currentPrice - sellerMoney;
             currentAuction.seller.transfer(sellerMoney);
             payable(owner).transfer(ownerMoney);
             emit AuctionEnded(index, currentPrice, msg.sender);
        }
}