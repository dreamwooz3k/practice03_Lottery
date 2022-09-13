// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Lottery{
    
    struct player {
        address addr;
        uint256 lot_num;
        bool win;
        uint balance;
    }
    bool check_claim;
    bool check_during;
    uint public start_time;
    uint16 public real_lottery_num;
    bool public winer;
    address public prev_sender;

    uint public check_time;

    player[] public player_list;

    constructor(){
        start_time=block.timestamp;
        real_lottery_num = 7777;
        check_claim=false;
        winer=false;
    }
    function buy(uint num) public payable
    {
        require(msg.value == 0.1 ether);

        if(prev_sender == msg.sender) {
            require(start_time + 24 hours >= block.timestamp);
            for(uint i=0; i<player_list.length; i++)
            {
                if(player_list[i].addr == msg.sender) 
                {
                    require(player_list[i].lot_num != num);
                }
            }
        }
        else 
        {
         require(start_time + 24 hours > block.timestamp);
        }

        player memory p;
        p.addr=msg.sender;
        prev_sender=msg.sender;
        p.lot_num=num;
        p.win=false;
        p.balance=0;
        player_list.push(p);
    }

    function draw() public
    {
        check_during=true;
        require(start_time + 24 hours <= block.timestamp);
        require(check_time != block.timestamp);
        uint reward = 0.1 ether;

        if(!winer && (block.timestamp > start_time + 24 hours))
        {
            start_time += 24 hours;
            reward += 0.1 ether;
        }

        for(uint i=0;i<player_list.length;i+=1)
        {
            if(player_list[i].lot_num == real_lottery_num) {
                player_list[i].balance += reward;
                player_list[i].win = true;
                winer=true;
            }
        }
    }

    function claim() public returns (bool)
    {
        uint256 bal;
        require(start_time + 24 hours - block.timestamp <= 0);
        for(uint i=0; i<player_list.length; i++)
        {
            if(player_list[i].addr==msg.sender)
            {
                bal=player_list[i].balance;
                player_list[i].balance=0;
            }
        }
        (bool send,) = payable(msg.sender).call{value:bal}("");
        check_time = block.timestamp;
    }
    
    function winningNumber() public returns (uint16)
    {
        return real_lottery_num;
    }
}