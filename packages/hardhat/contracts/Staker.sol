// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  event Stake(address,uint256);
  uint256 public deadline = block.timestamp + 72 hours;
  uint256 public Threshold= 1 ether;
  bool public openForWithdraw;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notCompleted {
    require(!exampleExternalContract.completed(),"Task is already completed");
    _;
  }

  function stake() payable public {
    balances[msg.sender]+=msg.value;
    emit Stake(msg.sender,msg.value);
  }

  function execute() public payable notCompleted{
    require(block.timestamp>=deadline);
    if(address(this).balance>=Threshold){
      exampleExternalContract.complete{value: address(this).balance}();
    }
    else {
      openForWithdraw=true;
    }
  }

  function withdraw() public payable{
    require(block.timestamp>=deadline);
    require(openForWithdraw);

    uint256 amount=balances[msg.sender];
    require(amount>0);

    balances[msg.sender] = 0; // Reset balance before transferring to avoid reentrancy
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Withdraw failed");
  }

  function timeLeft() public view returns (uint256){
    if(block.timestamp >= deadline){
      return 0;
    }
    else{
      return (deadline - block.timestamp);
    }
  }

  function receive() payable public{
    stake();
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()

}
