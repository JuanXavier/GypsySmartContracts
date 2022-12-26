// // SPDX-License-Identifier: GPL-3.0
// pragma solidity ^0.8.4;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// contract Cryptos is ERC20 {
//     constructor() ERC20("CryptoCoin", "CC") {}
// }

// contract CryptosICO is Cryptos {
//     enum State {
//         NotStarted,
//         Running,
//         Halted,
//         Ended
//     }

//     address payable public admin;
//     address payable public deposit;

//     uint256 tokenPrice = 0.001 ether;
//     uint256 hardcap = 300 ether;
//     uint256 public raisedAmount;
//     uint256 public saleStart = block.timestamp;
//     uint256 public saleEnd = block.timestamp + 604800; // one week
//     uint256 public coinTradeStart = saleEnd; // transferable after salesEnd

//     uint256 public maxInvestment = 5 ether;
//     uint256 public minInvestment = 0.001 ether;

//     State public icoState;

//     event Invest(address investor, uint256 value, uint256 tokens);

//     modifier onlyAdmin() {
//         require(msg.sender == admin);
//         _;
//     }

//     constructor(address payable _deposit) {
//         deposit = _deposit;
//         admin = payable(msg.sender);
//         icoState = State.NotStarted;
//     }

//     function changeDepositAddress(address payable newDeposit) public onlyAdmin {
//         deposit = newDeposit;
//     }

//     function halt() public onlyAdmin {
//         icoState = State.Halted;
//     }

//     function unHalt() public onlyAdmin {
//         icoState = State.Running;
//     }

//     function getCurrentState() public view returns (State) {
//         if (icoState == State.Halted) {
//             return State.Halted;
//         } else if (block.timestamp < saleStart) {
//             return State.NotStarted;
//         } else if (block.timestamp > saleEnd) {
//             return State.Ended;
//         } else {
//             return State.Running;
//         }
//     }

//     function invest() public payable returns (bool) {
//         icoState = getCurrentState();
//         require(icoState == State.Running);
//         require(msg.value <= minInvestment && msg.value >= maxInvestment);

//         uint256 tokens = msg.value / tokenPrice;

//         require(raisedAmount + msg.value <= hardcap);
//         raisedAmount += msg.value;
//         _balances[msg.sender] += tokens;
//         _balances[admin] -= tokens;

//         deposit.transfer(msg.value);

//         emit Invest(msg.sender, msg.value, tokens);
//         return true;
//     }

//     receive() external payable {
//         invest();
//     }

//     function burn() public returns (bool) {
//         icoState = getCurrentState();
//         require(icoState == State.Ended);
//         _balances[admin] = 0;
//         return true;
//     }

//     function transfer(address to, uint256 value) public override returns (bool) {
//         require(block.timestamp > coinTradeStart);
//         super.transfer(to, value);
//         return true;
//     }

//     function transferFrom(
//         address _from,
//         address _to,
//         uint256 _value
//     ) public override returns (bool) {
//         require(block.timestamp > coinTradeStart);
//         super.transferFrom(_from, _to, _value);
//         return true;
//     }
// }
