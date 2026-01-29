// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract MiniBank{

    address public owner;

    struct User {
        uint256 balance;
    }

    mapping(address => User) private users;

    // EVENTS
    event Deposited(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    // CUSTOM ERRORS
    error NotOwner();
    error InsufficientBalance(uint256 requested, uint256 available);
    error ZeroAmount();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    function deposite() external payable {
        if (msg.value == 0) revert ZeroAmount();

        users[msg.sender].balance += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        uint256 userBalance = users[msg.sender].balance;

        if(_amount == 0) revert ZeroAmount();
        if(userBalance < _amount) revert InsufficientBalance(_amount, userBalance);

        users[msg.sender].balance = userBalance - _amount;

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "ETH transfer failed");

        emit Withdraw(msg.sender, _amount);
    }

    function balanceOf(address _user) external view returns (uint256) {
        return users[_user].balance;
    }

    function bankBalance() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }

}
