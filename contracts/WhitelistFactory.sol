// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./_ownable.sol";

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

    /// @notice Modifeir to check if the sender is owner of the contract, access modifier
    modifier onlyManager(bytes32 _whitelistId) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId) {
                require(whitelist[i].id == _whitelistId, "not found");
                require(msg.sender == whitelist[i].manager, "you are not the manager of this....");
            }
        }
        _;
    }

    /// @notice Create a new whitelist
    /// @dev If the manager field is left empty, the sender will be recognized as the manager
    /// @param _metadata The IPFS CID => bafybeia4khbew3r2mkflyn7nzlvfzcb3qpfeftz5ivpzfwn77ollj47gqi
    /// @param startTime Time in timestamp format => 1745534812
    /// @return Whitelist id
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

    //
    function getWhitelist(bytes32 _whitelistId) public view returns (whitelistStruct[] memory) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId) {
                return whitelist;
            }
        }

        revert("The whitelist that has been entered has not been declared yet");
    }

    // check if sender is the manager of the whitelist
    // returns boolean
    function updateWhitelist(
        bytes32 _whitelistId,
        string memory _metadata,
        bool _pause
    ) public onlyManager(_whitelistId) returns (bool) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId) {
                whitelist[i].metadata = _metadata;
                whitelist[i].pause = _pause;

                // Emit that the whitelist updated
                return true;
            }
        }
        return false;
    }

    function getWhitelistCount() public view returns (uint256) {
        return whitelist.length;
    }

    /// @notice Add user to a whitelist
    function addUser(bytes32 _whitelistId) public {
        /// @notice Revert the transaction if the whitelist ID is not valid, not open, or has expired
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId) {
                require(!whitelist[i].pause, "The whitelist ID you entered has been paused");
                if (whitelist[i].endTime < block.timestamp) revert("The entered whitelist is expired");
            } else {
                revert("The ID you entered does not have a whitelist associated with it.");
            }
        }

        /// @notice Check the sender is not exist on the whitelist
        for (uint256 i = 0; i < user.length; i++) {
            if (user[i].sender == msg.sender && user[i].whitelistId == _whitelistId)
                revert("The Sender is already on the list");
        }

        /// @notice Add new user
        user.push(UserStruct(_whitelistId, msg.sender));

        /// @notice Emit new user has been added
        emit Log("New user", gasleft());
    }

    /// @notice Get users list of a whitelist
    function getUserList(bytes32 _whitelistId) external view returns (address[] memory) {
        address[] memory userList = new address[](user.length);
        uint256 userCountr = 0;

        for (uint256 i = 0; i < user.length; i++) {
            if (user[i].whitelistId == _whitelistId) {
                userList[userCountr] = user[i].sender;
                userCountr++;
            }
        }

        return userList;
    }

    /// @notice Verify if a user is on a specific whitelist
    /// @return Whitelist ID
    function verifyUser(address _address) public view returns (bytes32) {
        for (uint256 i = 0; i < user.length; i++) {
            if (user[i].sender == _address) return user[i].whitelistId;
        }

        return bytes32(0);
    }

    /// @notice Add user by the manager of the whitelist
    function addUserByManager(address _addr, bytes32 _whitelistId) public onlyManager(_whitelistId) {
        /// @notice Check the sender is not exist on the whitelist
        for (uint256 i = 0; i < user.length; i++) {
            if (user[i].sender == _addr && user[i].whitelistId == _whitelistId)
                revert("The sender is already on the list");
        }
        user.push(UserStruct(_whitelistId, _addr));

        /// @notice Emit new user has been added
        emit Log("New user", gasleft());
    }

    /// @notice Add user by the manager of the whitelist
    function removeUserByManager(address _addr, bytes32 _whitelistId) public onlyManager(_whitelistId) returns (bool) {
        /// @notice Check the sender is not exist on the whitelist
        for (uint256 i = 0; i < user.length; i++) {
            if (user[i].sender == _addr && user[i].whitelistId == _whitelistId) {
                delete user[0];
                return true;
            }
        }

        return false;
    }

    function getUserCount() public view returns (uint256) {
        return user.length;
    }
}
