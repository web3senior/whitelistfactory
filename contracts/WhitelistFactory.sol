// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "Ownable.sol";

/// @title A whitelist contract for NFT lovers
/// @author Amir Rahimi
/// @notice Read the use cases before deploying the contract
/// @dev Run test before deploying, you can find deployed contract addresses in deployed dir
contract WhitelistFactory is Ownable {
    /// @notice Current count
    uint256 private count = 0;

    error TooEarly(uint256 time);

    error TooLate(uint256 time);

    event WhitelistCreated(
        address indexed sender,
        bytes32 indexed id,
        string metadata,
        uint256 startTime,
        uint256 endTime,
        address indexed manager,
        bool pause
    );

    event Log(string func, uint256 gas);

    struct whitelistStruct {
        bytes32 id;
        string metadata;
        uint256 startTime;
        uint256 endTime;
        address manager;
        bool pause;
    }

    whitelistStruct[] public whitelist;

    struct UserStruct {
        bytes32 whitelistId;
        address sender;
    }

    UserStruct[] private user;

    constructor() {
        /// @dev Assert that count will start from 0
        assert(count == 0);

        /// @dev Assert that owner is equal to msg.sender
        assert(msg.sender == owner);
    }

    // @notice: Create a new whitelist
    // @param _metadata The IPFS CID => bafybeia4khbew3r2mkflyn7nzlvfzcb3qpfeftz5ivpzfwn77ollj47gqi
    // @param startTime Time in timestamp format => 1745534812
    // @return Whitelist id
    function addWhitelist(
        string memory _metadata,
        uint256 startTime,
        uint256 endTime,
        address manager
    ) public returns (bytes32) {
        /// @notice Continue if start time is gretter that current time
        require(startTime > block.timestamp, "Start time must be greater than current time");

        /// @notice Continue if end time is gretter than start time
        require(endTime > startTime, "End time must be greater than start time");

        /// @notice Increase counter
        ++count;

        /// @notice Add a new whitelist
        whitelist.push(whitelistStruct(bytes32(count), _metadata, startTime, endTime, manager, false));

        /// @notice Emit new whitelist data
        emit WhitelistCreated(msg.sender, bytes32(count), _metadata, startTime, endTime, manager, false);

        return bytes32(count);
    }

    // isActivePool
    function getWhitelist(bytes32 _whitelistId) public view returns (whitelistStruct[] memory) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId) return whitelist;
        }

        revert();
    }

    // check if sender is the manager of the whitelist
    // returns boolean
    function updateWhitelist(bytes32 _whitelistId, string memory _metadata, bool _pause) public returns (bool) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId && msg.sender == whitelist[i].manager) {
                whitelist[i].metadata = _metadata;
                whitelist[i].pause = _pause;
                return true;
            }
        }
        return false;
    }

    function whitelistCount() public view returns (uint256) {
        return whitelist.length;
    }

    function addUser(bytes32 _whitelistId) public returns (bool) {
        for (uint256 i = 0; i < user.length; i++) {
            if (user[i].sender == msg.sender && user[i].whitelistId == _whitelistId) {
                revert();
            }
        }
        emit Log("New Address", gasleft());
        user.push(UserStruct(_whitelistId, msg.sender));
        return true;
    }

    // return whitelist ID if a user exists
    function verifyUser(address _address) public view returns (bytes32) {
        for (uint256 i = 0; i < user.length; i++) {
            if (user[i].sender == _address) return user[i].whitelistId;
        }

        return bytes32(0);
    }
}
