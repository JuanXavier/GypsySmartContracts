//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract AuctionCreator {
    Auction[] public auctions;

    function createAuction() public {
        Auction newAuction = new Auction(payable(msg.sender));
        auctions.push(newAuction);
    }
}

contract Auction {
    enum State {
        Running,
        Ended,
        Canceled
    }

    address payable public owner;
    uint256 public startTime;
    uint256 public endTime;
    string public ipfsHash = "";
    uint256 public bidIncrement = 1 ether;
    uint256 public highestBindingBid;
    address payable public highestBidder;

    State public auctionState;

    mapping(address => uint256) public bids;

    constructor(address payable creator) {
        owner = creator;
        auctionState = State.Running;
        startTime = block.number;
        endTime = startTime + 4;
    }

    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }

    modifier notOwner() {
        require(msg.sender != owner);
        _;
    }

    modifier afterStart() {
        require(block.number >= startTime);
        _;
    }

    modifier beforeEnd() {
        require(block.number <= endTime);
        _;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        // function que determina el valor minimo entre 2 cantidades
        if (a <= b) {
            return a;
        } else {
            return b;
        }
    }

    function placeBid() public payable notOwner afterStart beforeEnd returns (bool) {
        require(auctionState == State.Running && msg.value >= 1 wei); // state must be running and value must be 0,01 ether
        uint256 currentBid = bids[msg.sender] + msg.value; // suma el primer valor del comprador mas el 2do
        require(currentBid > highestBindingBid); // necesito que el bid actual sea mayor que el Bbid mas alto.
        bids[msg.sender] = currentBid; // actualizo el mapping bids con el sender y el bid actual

        if (currentBid <= bids[highestBidder]) {
            // si el bid actual es menor o igual al bid mas alto, se actualiza el binding bid pero el bidder mas alto se mantiene igual
            highestBindingBid = min(currentBid + bidIncrement, bids[highestBidder]); // el Bbid es el valor min entre a)el bid actual mas el incremento, y b) el valor del mayor bidder.
        } else {
            highestBindingBid = min(currentBid, bidIncrement + bids[highestBidder]);
            highestBidder = payable(msg.sender); // act5ualiza el mayor bidder a quien utiliza esta funcion
        }
        return true;
    }

    function cancelAuction() public ownerOnly {
        auctionState = State.Canceled;
    }

    function endAuction() public {
        require(auctionState == State.Canceled || block.number > endTime);
        require(msg.sender == owner || bids[msg.sender] > 0);
        address payable recipient;
        uint256 value;

        if (auctionState == State.Canceled) {
            //si la subasta esta cancelada, cada uno puede retirar su dinero manualmente
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        } else {
            //la subasta ha terminado y cada uno retira su dinero
            if (msg.sender == owner) {
                // cuando el dueno ejecuta la funcion, recibe el valor del Bindingbid
                recipient = owner;
                value = highestBindingBid;
            } else {
                // cuando un bidder requiere sus fondos
                if (msg.sender == highestBidder) {
                    // si es el bidder mas alto, recibe el valor que recibe es la diferencia entre Bbid y su apuesta maxima
                    recipient = payable(highestBidder);
                    value = bids[highestBidder] - highestBindingBid;
                } else {
                    // si no es el bidder maximo, retira el valor maximo apostado
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }
        recipient.transfer(value); //transfer value to recipient
    }
}
