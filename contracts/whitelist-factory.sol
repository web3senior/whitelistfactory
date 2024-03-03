// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./_ownable.sol";

/// @title A whitelist contract for NFT lovers
/// @author Amir Rahimi
/// @notice Read the use cases before deploying the contract
/// @dev Run test before deploying, you can find deployed contract addresses in deployed dir
contract WhitelistFactory is Ownable(msg.sender) {
    /// @notice Current count
    uint256 public count = 0;

    error TooEarly(uint256 time);

    error TooLate(uint256 time);

    /// Sender not authorized for this
    error Unauthorized();

    event WhitelistCreated(
        address indexed sender,
        bytes32 indexed id,
        string metadata,
        uint256 startTime,
        uint256 endTime,
        address indexed manager,
        bool pause,
        address[] users
    );

    event Log(string func, uint256 gas);

    struct whitelistStruct {
        bytes32 id;
        string metadata;
        uint256 startTime;
        uint256 endTime;
        address manager;
        bool pause;
        address[] users;
    }

    whitelistStruct[] private whitelist;

    constructor() {
        /// @dev Assert that count will start from 0
        assert(count == 0);
    }

    /**
     * @dev Throws if called by any account other than the manager.
     */
    modifier onlyManager(bytes32 _whitelistId) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId) {
                require(whitelist[i].manager == msg.sender, "you are not the manager of this....");
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
        address manager,
        address[] memory users
    ) public returns (bytes32) {
        /// @notice Continue if start time is gretter that current time
        require(startTime > block.timestamp, "Start time must be greater than current time");

        /// @notice Continue if end time is gretter than start time
        require(endTime > startTime, "End time must be greater than start time");

        /// @notice Increase counter
        ++count;

        /// @notice Add a new whitelist
        whitelist.push(whitelistStruct(bytes32(count), _metadata, startTime, endTime, manager, false, users));

        /// @notice Emit new whitelist data
        emit WhitelistCreated(msg.sender, bytes32(count), _metadata, startTime, endTime, manager, false, users);

        return bytes32(count);
    }

    //
    function getWhitelist(bytes32 _whitelistId) public view returns (whitelistStruct memory) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId) {
                return whitelist[i];
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

    function whitelistTotal() public view returns (uint256) {
        return whitelist.length;
    }

    /// @notice Add user to a whitelist
    function addUser(bytes32 _whitelistId) public returns (bool) {
        /// @notice Revert the transaction if the whitelist ID is not valid, not open, or has expired
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId) {
                if (whitelist[i].startTime < block.timestamp) revert TooEarly(block.timestamp);
                if (whitelist[i].endTime < block.timestamp) revert TooLate(block.timestamp);
                if (whitelist[i].pause) revert("This whitelist has been paused");

                /// @notice Check the sender is not exist on the whitelist
                for (uint256 q = 0; q < whitelist[i].users.length; q++)
                    require(whitelist[i].users[q] != msg.sender, "The Sender is already on the list");

                /// @notice Add new user
                whitelist[i].users.push(msg.sender);

                /// @notice Emit new user has been added
                emit Log("New user", gasleft());

                return true;
            }
        }
        return false;
    }

    /// @notice Get users list of a whitelist
    function getUserList(bytes32 _whitelistId) external view returns (address[] memory) {
        address[] memory users;

        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId) {
                return whitelist[i].users;
            }
        }

        return users;
    }

    /// @notice Verify if a user is on a specific whitelist
    /// @return Whitelist ID
    function verifyUser(bytes32 _whitelistId, address _addr) public view returns (bool) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId) {
                for (uint256 u = 0; u < whitelist[i].users.length; u++) {
                    if (whitelist[i].users[u] == _addr) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    /// @notice Verify if a user is on a specific whitelist
    /// @return Whitelist ID
    function verifyManager(bytes32 _whitelistId, address _manager) public view returns (bool) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId && whitelist[i].manager == _manager) {
                return true;
            }
        }
        return false;
    }

    /// @notice Add user by the manager of the whitelist
    function setUserBatch(address[] memory _addrs, bytes32 _whitelistId) public onlyManager(_whitelistId) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId) {
                for (uint256 a = 0; a < _addrs.length; a++) {
                    for (uint256 u = 0; u < whitelist[i].users.length; u++) {
                        if (whitelist[i].users[u] != _addrs[a]) {
                            whitelist[i].users.push(_addrs[a]);
                        }
                    }
                }
            }
        }
    }

    /// @notice Add user by the manager of the whitelist
    function removeUserByManager(address _addr, bytes32 _whitelistId) public onlyManager(_whitelistId) returns (bool) {
        /// @notice Check the sender is not exist on the whitelist
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId) {
                for (uint256 u = 0; u < whitelist[i].users.length; u++) {
                    if (whitelist[i].users[u] != _addr) {
                        delete whitelist[i].users[u];
                        return true;
                    }
                }
            }
        }

        return false;
    }

    function getUserTotal(bytes32 _whitelistId) public view returns (uint256) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i].id == _whitelistId) return whitelist[i].users.length;
        }

        revert("Whitelist Not Found!");
    }
}
