// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interface/IERC20.sol";

contract SwapToken {

    uint256 public nextOrderId;
    
    struct TokenOrder {
        address seller;
        address tokenToSell;
        uint256 amountToSell;
        address tokenToBuy;
        uint256 amountToBuy;
    }
 
    mapping(uint256 => TokenOrder) public orders;
    

    event OrderCreated(uint256 indexed orderId, address indexed seller, address tokenToSell, uint256 amountToSell, address tokenToBuy, uint256 amountToBuy);
    event OrderFulfilled(uint256 indexed orderId, address indexed buyer);
    event OrderCancelled(uint256 indexed orderId);

    function createOrder(address _tokenToSell, uint256 _amountToSell, address _tokenToBuy, uint256 _amountToBuy) external {
        require(_tokenToSell != address(0), "Zero Address Detected");
        require(_tokenToBuy != address(0), "Zero Address Detected");
        require(_amountToSell > 0, "Zero Ammount Not Allowed");
        require(_amountToBuy > 0, "Zero Ammount Not Allowed");

        IERC20(_tokenToSell).transferFrom(msg.sender, address(this), _amountToSell);

        orders[nextOrderId] = TokenOrder({
            seller: msg.sender,
            tokenToSell: _tokenToSell,
            amountToSell: _amountToSell,
            tokenToBuy: _tokenToBuy,
            amountToBuy: _amountToBuy
        });

        emit OrderCreated(nextOrderId, msg.sender, _tokenToSell, _amountToSell, _tokenToBuy, _amountToBuy);
        nextOrderId++;
    }


    function fulfillOrder(uint256 _orderId) external {
        TokenOrder storage order = orders[_orderId];
        require(order.seller != address(0), "Zero Address Detected");

        IERC20(order.tokenToBuy).transferFrom(msg.sender, order.seller, order.amountToBuy);
        IERC20(order.tokenToSell).transfer(msg.sender, order.amountToSell);

        emit OrderFulfilled(_orderId, msg.sender);
        delete orders[_orderId];
    }


    function cancelOrder(uint256 _orderId) external {
        TokenOrder storage order = orders[_orderId];
        require(order.seller == msg.sender, "Not The Order Creator");

        IERC20(order.tokenToSell).transfer(msg.sender, order.amountToSell);

        emit OrderCancelled(_orderId);
        delete orders[_orderId];
    }

}