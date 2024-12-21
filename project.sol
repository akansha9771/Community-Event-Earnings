// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CommunityEventEarnings {
    struct Event {
        uint id;
        string name;
        address organizer;
        uint256 earnings;
        bool isCompleted;
    }

    mapping(uint => Event) public events;
    mapping(address => uint256) public earnings;
    uint public eventsCount;

    event EventCreated(uint id, string name, address organizer);
    event EarningsDistributed(uint id, uint256 amount);
    event EventCompleted(uint id);

    constructor() {
        eventsCount = 0;
    }

    function createEvent(string memory _name) public {
        eventsCount++;
        events[eventsCount] = Event(eventsCount, _name, msg.sender, 0, false);
        emit EventCreated(eventsCount, _name, msg.sender);
    }

    function contributeToEvent(uint _eventId) public payable {
        require(_eventId > 0 && _eventId <= eventsCount, "Invalid event ID.");
        require(!events[_eventId].isCompleted, "Event is already completed.");
        require(msg.value > 0, "Contribution must be greater than zero.");

        events[_eventId].earnings += msg.value;
        earnings[events[_eventId].organizer] += msg.value;
    }

    function completeEvent(uint _eventId) public {
        require(_eventId > 0 && _eventId <= eventsCount, "Invalid event ID.");
        require(msg.sender == events[_eventId].organizer, "Only the organizer can complete the event.");
        require(!events[_eventId].isCompleted, "Event is already completed.");

        events[_eventId].isCompleted = true;
        emit EventCompleted(_eventId);
    }

    function withdrawEarnings() public {
        uint256 amount = earnings[msg.sender];
        require(amount > 0, "No earnings to withdraw.");

        earnings[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit EarningsDistributed(eventsCount, amount);
    }

    function getEvent(uint _eventId) public view returns (uint, string memory, address, uint256, bool) {
        require(_eventId > 0 && _eventId <= eventsCount, "Invalid event ID.");
        Event memory eventDetails = events[_eventId];
        return (eventDetails.id, eventDetails.name, eventDetails.organizer, eventDetails.earnings, eventDetails.isCompleted);
    }
}