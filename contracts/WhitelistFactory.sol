// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title A whitelist contract for NFT lovers
/// @author Amir Rahimi
/// @notice This contrct is deployed
/// @dev Run test before deploying, you can find deployed contract addresses in deployed dir
contract WhitelistFactory {
    /// @notice Owner address
    address public owner;

    /// @notice Current count
    uint256 public count = 0;

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

    struct WhitelistStruct {
        bytes32 id;
        string metadata;
        uint256 startTime;
        uint256 endTime;
        address manager;
        bool pause;
    }

    WhitelistStruct[] public whitelists;

    struct SubscribeStruct {
        bytes32 whitelistId;
        address sender;
    }

    SubscribeStruct[] public subscribes;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You aren't the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    // @notice: Create a new whitelist
    // @param _metadata The IPFS CID => bafybeia4khbew3r2mkflyn7nzlvfzcb3qpfeftz5ivpzfwn77ollj47gqi
    // @param startTime Time in timestamp format => 1705534812
    // @return Whitelist id
    function newWhitelist(
        string memory _metadata,
        uint256 startTime,
        uint256 endTime,
        address manager
    ) external returns (bytes32) {
        /// @notice Increase the current value of count
        ++count;

        require(startTime > block.timestamp && endTime > startTime, 'Start time must be greater than current time');

        /// @dev Stores the new whitelist in the whielist array
        whitelists.push(WhitelistStruct(bytes32(count), _metadata, startTime, endTime, manager, false));

        /// @notice Emit the new whitelist
        emit WhitelistCreated(msg.sender, bytes32(count), _metadata, startTime, endTime, manager, false);

        return bytes32(count);
    }

    // isActivePool
    function isActiveWhitelist(bytes32 _whitelistId) public view returns (bool) {
        for (uint256 i = 0; i < whitelists.length; i++) {
            if (whitelists[i].id == _whitelistId) return !whitelists[0].pause;
        }

        revert();
    }

    // 1717958989
    function updateWhitelist(bytes32 _whitelistId, string memory _metadata, bool _pause) public returns (bool) {
        for (uint256 i = 0; i < whitelists.length; i++) {
            if (whitelists[i].id == _whitelistId && msg.sender == whitelists[i].manager) {
                whitelists[i].metadata = _metadata;
                whitelists[i].pause = _pause;
                return true;
            }
        }
        return false;
    }

    function getWhitelistCount() public view returns (uint256) {
        return whitelists.length;
    }

    // function subscribe(bytes32 _whitelistId) public {
    //     for (uint256 i = 0; i < whitelist.length; i++) {
    //         if (whitelist[i].id == _whitelistId && msg.sender == whitelist[i].manager) {
    //             //whitelist[i].metadata = _metadata;
    //             //whitelist[i].pause = _pause;
    //            // return true;
    //         }
    //     }

    //     emit Log('New Subscription', gasleft());
    //     subscribes.push(SubscribeStruct(_whitelistId, msg.sender));
    // }

    // isInSubscriptionList
    // function isInSubscriptionList(address _address) public view returns (bytes32) {
    //     for (uint256 i = 0; i < subscribes.length; i++) {
    //         if (subscribes[i].sender == _address) return subscribes[i].whitelistId;
    //     }
    // }

    function getSubscribeOverall() public view returns (uint256) {
        return subscribes.length;
    }
}
