// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Access control
/// @dev The owner will be the one who deploys the contract
contract Ownable {
    /// @notice Owner wallet address
    address internal owner;

    /// Sender not authorized for this
    error Unauthorized();

    event OwnerSet(address indexed owner);

    /// @notice Declare sender as an owner of this contract
    /// @dev Or put the owner address directly in owner variable owner = 0x0
    constructor() {
        owner = msg.sender;
        emit OwnerSet(owner);
    }

    /// @notice Modifeir to check if the sender is owner of the contract, access modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Sender not authorized as owner");
        _;
    }

    /// @notice Transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
        emit OwnerSet(owner);
    }

    /// @notice Get contract owner
    function getOwner() public view returns (address) {
        return owner;
    }
}
