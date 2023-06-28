// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract InsurancePeerPool {
    struct Member {
        uint256 contribution;   // Contribution amount from member
        uint256 insuranceAmount;  // Insurance amount allocated to the member
        bool isActive;  // Whether the member is active or not
    }

    mapping(address => Member) public members;
    address[] public memberAddresses;
    address public owner;

    event ContributionAdded(address indexed member, uint256 contribution);
    event InsuranceClaimed(address indexed member, uint256 amount);
    event ContributionWithdrawn(address indexed member, uint256 amount);
    event InsuranceAllocated(address indexed member, uint256 amount);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    modifier onlyActiveMember() {
        require(members[msg.sender].isActive, "You are not an active member.");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function join() external payable {
        require(!members[msg.sender].isActive, "You are already a member.");
        require(msg.value > 0, "Contribution amount must be greater than 0.");

        Member memory newMember = Member({
            contribution: msg.value,
            insuranceAmount: 0,
            isActive: true
        });

        members[msg.sender] = newMember;
        memberAddresses.push(msg.sender);

        emit ContributionAdded(msg.sender, msg.value);
    }

    function contribute() external payable onlyActiveMember {
        require(msg.value > 0, "Contribution amount must be greater than 0.");

        members[msg.sender].contribution += msg.value;

        emit ContributionAdded(msg.sender, msg.value);
    }

    function claimInsurance(uint256 amount) external onlyActiveMember {
        require(amount > 0, "Claim amount must be greater than 0.");
        require(amount <= members[msg.sender].insuranceAmount, "Insufficient insurance amount.");

        members[msg.sender].insuranceAmount -= amount;
        payable(msg.sender).transfer(amount);

        emit InsuranceClaimed(msg.sender, amount);
    }

    function withdrawContribution(uint256 amount) external onlyActiveMember {
        require(amount > 0, "Withdrawal amount must be greater than 0.");
        require(amount <= members[msg.sender].contribution, "Insufficient contribution balance.");

        members[msg.sender].contribution -= amount;
        payable(msg.sender).transfer(amount);

        emit ContributionWithdrawn(msg.sender, amount);
    }

    function allocateInsurance(address memberAddress, uint256 amount) external onlyOwner {
        require(members[memberAddress].isActive, "Member is inactive.");
        require(amount > 0, "Allocation amount must be greater than 0.");

        members[memberAddress].insuranceAmount += amount;

        emit InsuranceAllocated(memberAddress, amount);
    }

    function deactivateMember(address memberAddress) external onlyOwner {
        require(members[memberAddress].isActive, "Member is already inactive.");
        members[memberAddress].isActive = false;
    }

    function activateMember(address memberAddress) external onlyOwner {
        require(!members[memberAddress].isActive, "Member is already active.");
        members[memberAddress].isActive = true;
    }

    function getMemberCount() public view returns (uint256) {
        return memberAddresses.length;
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdrawFunds(uint256 amount) external onlyOwner {
        require(amount > 0, "Withdrawal amount must be greater than 0.");
        require(amount <= address(this).balance, "Insufficient contract balance.");
            payable(msg.sender).transfer(amount);

    emit FundsWithdrawn(msg.sender, amount);
}
}
