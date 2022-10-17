--PRINT OPTIONS
| 11 | inheritance | Print the inheritance relations between contracts |
| 4 | contract-summary | Print a summary of the contracts |
| 10 | human-summary | Print a human-readable summary of the contracts |
| 9 | function-summary | Print a summary of the functions |
| 8 | function-id | Print the keccack256 signature of the functions |

| 3 | constructor-calls | Print the constructors executed |
| 13 | modifiers | Print the modifiers called by each function |
| 15 | require | Print the require and assert calls of each function |
| 18 | variable-order | Print the storage order of the state variables |
| 19 | vars-and-auth | Print the state variables written and the authorization of the functions |
| 5 | data-dependency | Print the data dependencies of the variables |

| 6 | echidna | Export Echidna guiding information |
| 7 | evm | Print the evm instructions of nodes in functions |
| 16 | slithir | Print the slithIR representation of the functions |  
| 17 | slithir-ssa | Print the slithIR representation of the functions |

| 1 | call-graph | Export the call-graph of the contracts to a dot file |
| 2 | cfg | Export the CFG of each functions |
| 12 | inheritance-graph | Export the inheritance graph of each contract to a dot file |

| 14 | pausable | Print functions that do not use whenNotPaused |
+-----+-------------------+--------------------------------------------------------------------------+

1. Audit the following Solidity files:
   - [StakingFacet.sol](contracts/facets/StakingFacet.sol)
   - [TicketsFacet.sol](contracts/facets/TicketsFacet.sol)
   - [Airdop.sol](contracts/Airdop.sol)
   - [StakingDiamond.sol](contracts/StakingDiamond.sol)
   - [AppStorage.sol](contracts/libraries/AppStorage.sol)
   - [LibStrings.sol](contracts/libraries/LibStrings.sol)

Pragma version^0.8.0 (contracts/libraries/LibStrings.sol#2) allows old versions
solc-0.8.9 is not recommended for deployment
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity

STAKINGFACET

- Informational. Following solidity style guide, there are blank lines between function that can be deleted.
  1 blank line above and 2 beloe stakePoolTokens functions,, and one blank line below the staked function

STAKINGDIAMOND

- how is it deployed?
  -test sending eth to it
- case 0 and default are the same
- struct should be before event
- line 31 initilializes at zero
- th appstorage stutc can be called but not the ticket or account
- the strcut on line 25 can be ommitted for saving gas since it has only an address

AIRROP

- The Airdrop contract file in named Airrop.
- Tre transfer on line 21 is a bad pratice. It is recommended to use .call instead
- The low-loevel transfer function is executed sending ETH from the smart contract to an arbitrary address

TicketsFacet

- There is a struct in the middle of nowehre on line 210.
- Extra space on require statement fo line 43
- line 70, require statemnt checks that

APPSTORAGE

- The content of the file is not inside a library.

**\*\***\*\***\*\\\***\*\*** SLITHER TESTS**\*\***\*\*\*\***\*\*\*\***\*\***

/\***\*\*\*\*\*\*\*\***\*\*\*\*** HIGH**\*\*\*\*\*\*\*\*\*\*\*\*\*

Airdrop.airdropMatic(address[],uint256[]) (contracts/Airrop.sol#18-23) sends eth to arbitrary user
Dangerous calls: - \_receivers[i].transfer(\_amounts[i]) (contracts/Airrop.sol#21)

Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#functions-that-send-ether-to-arbitrary-destinations

StakingFacet.stakePoolTokens(uint256) (contracts/facets/StakingFacet.sol#78-83) ignores return
value by IERC20(s.poolContract).transferFrom(tx.origin,address(this),\_poolTokens) (contracts/facets/StakingFacet.sol#82)

StakingFacet.withdrawPoolStake(uint256) (contracts/facets/StakingFacet.sol#98-104) ignores return value by IERC20(s.poolContract).transfer(tx.origin,\_poolTokens) (contracts/facets/StakingFacet.sol#103)

Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unchecked-transfer

/\***\*\*\*\*\*\*\***\*\***\*\*\*\*\*\*\*** MEDIUM **\*\*\*\***\*\*\*\***\*\*\*\***\*\*\***\*\*\*\***\*\*\*\***\*\*\*\***

Airdrop.airdropToken(address,address[],uint256[]) (contracts/Airrop.sol#7-16) uses tx.origin for authorization: require(bool,string)(IERC20(\_token).transferFrom(tx.origin,\_receivers[i],\_amounts[i]),Token send failed) (contracts/Airrop.sol#14)

StakingFacet.claimTickets(uint256[],uint256[]) (contracts/facets/StakingFacet.sol#106-137) uses tx.origin for authorization: require(bool,string)(ERC1155_BATCH_ACCEPTED == IERC1155TokenReceiver(tx.origin).onERC1155BatchReceived(tx.origin,address(0),\_ids,\_values,new bytes(0)),Staking:
Ticket transfer rejected/failed) (contracts/facets/StakingFacet.sol#132-135)

TicketsFacet.safeTransferFrom(address,address,uint256,uint256,bytes) (contracts/facets/TicketsFacet.sol#61-90) uses tx.origin for authorization: require(bool,string)(\_from == tx.origin || s.accounts[_from].ticketsApproved[tx.origin],Tickets: Not approved to transfer) (contracts/facets/TicketsFacet.sol#70)

TicketsFacet.safeTransferFrom(address,address,uint256,uint256,bytes) (contracts/facets/TicketsFacet.sol#61-90) uses tx.origin for authorization: require(bool,string)(ERC1155_ACCEPTED == IERC1155TokenReceiver(\_to).onERC1155Received(tx.origin,\_from,\_id,\_value,\_data),Tickets: Transfer rejected/failed by \_to) (contracts/facets/TicketsFacet.sol#85-88)

TicketsFacet.safeBatchTransferFrom(address,address,uint256[],uint256[],bytes) (contracts/facets/TicketsFacet.sol#108-144) uses tx.origin for authorization: require(bool,string)(\_from == tx.origin || s.accounts[_from].ticketsApproved[tx.origin],Tickets: Not approved to transfer) (contracts/facets/TicketsFacet.sol#117)

TicketsFacet.safeBatchTransferFrom(address,address,uint256[],uint256[],bytes) (contracts/facets/TicketsFacet.sol#108-144) uses tx.origin for authorization: require(bool,string)(ERC1155_BATCH_ACCEPTED == IERC1155TokenReceiver(\_to).onERC1155BatchReceived(tx.origin,\_from,\_ids,\_values,\_data),Tickets: Transfer rejected/failed by \_to) (contracts/facets/TicketsFacet.sol#139-142)

Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dangerous-usage-of-txorigin

StakingFacet.migrateFrens(address[],uint256[]).i (contracts/facets/StakingFacet.sol#61) is a local variable never initialized

LibDiamond.removeFunctions(address,bytes4[]).selectorIndex (contracts/libraries/LibDiamond.sol#113) is a local variable never initialized

TicketsFacet.migrateTickets(TicketsFacet.TicketOwner[]).i (contracts/facets/TicketsFacet.sol#217) is a local variable never initialized

TicketsFacet.balanceOfAll(address).i (contracts/facets/TicketsFacet.sol#160) is a local variable never initialized

StakingFacet.bulkFrens(address[]).i (contracts/facets/StakingFacet.sol#27) is a local variable never initialized

Airdrop.airdropMatic(address[],uint256[]).i (contracts/Airrop.sol#20) is a local variable never initialized

Airdrop.airdropToken(address,address[],uint256[]).i (contracts/Airrop.sol#13) is a local variable never initialized

StakingFacet.updateAccounts(address[]).i (contracts/facets/StakingFacet.sol#40) is a local variable never initialized

TicketsFacet.balanceOfBatch(address[],uint256[]).i (contracts/facets/TicketsFacet.sol#184) is a local variable never initialized

LibDiamond.diamondCut(IDiamondCut.FacetCut[],address,bytes).facetIndex (contracts/libraries/LibDiamond.sol#59) is a local variable never initialized

TicketsFacet.migrateTickets(TicketsFacet.TicketOwner[]).j (contracts/facets/TicketsFacet.sol#222) is a local variable never initialized

LibDiamond.replaceFunctions(address,bytes4[]).selectorIndex (contracts/libraries/LibDiamond.sol#96) is a local variable never initialized

TicketsFacet.setBaseURI(string).i (contracts/facets/TicketsFacet.sol#37) is a local variable never initialized

TicketsFacet.totalSupplies().i (contracts/facets/TicketsFacet.sol#148) is a local variable never initialized

LibDiamond.addFunctions(address,bytes4[]).selectorIndex (contracts/libraries/LibDiamond.sol#81) is a local variable never initialized

Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#uninitialized-local-variables

/\***\*\*\*\*\*\*\***\*\***\*\*\*\*\*\*\*** LOW **\*\*\*\***\*\*\*\***\*\*\*\***\*\*\***\*\*\*\***\*\*\*\***\*\*\*\***

Airdrop.airdropToken(address,address[],uint256[]) (contracts/Airrop.sol#7-16) hous-usage-of-txoas external calls inside a loop: require(bool,string)(IERC20(\_token).transferFrom(tx.origin,\_receivers[i],\_amounts[i]),Token send failed) (contracts/Airrop.sol#14) .sol#61)
is a lo
Airdrop.airdropMatic(address[],uint256[]) (contracts/Airrop.sol#18-23) has external calls inside a loop: \_receivers[i].transfer(\_amounts[i]) (contracts/Airrop/LibDiamond.sol#.sol#21)

Reference: https://github.com/crytic/slither/wiki/Detector-Documentation/#callsketsFacet.sol#21-inside-a-loop
a local variabl

StakingFacet.withdrawPoolStake(uint256) (contracts/facets/StakingFacet.sol#98-104) uses timestamp for comparisons local variable

Dangerous comparisons: - require(bool,string)(accountPoolTokens >= \_poolTokens,Can't withdraw l variable never
more poolTokens than in account) (contracts/facets/StakingFacet.sol#101)

StakingFacet.claimTickets(uint256[],uint256[]) (contracts/facets/StakingFacet.ss a local variabol#106-137) uses timestamp for comparisons

Dangerous comparisons: is a local vari - require(bool,string)(frensBal >= cost,Staking: Not enough frens points) (contracts/facets/StakingFacet.sol#118) et.sol#184) is a

Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#block-timestamp

/\***\*\*\*\*\*\*\*\***\*\*\*\*** informational**\*\*\*\*\*\*\*\*\*\*\*\*\*
StakingDiamond.fallback() (contracts/StakingDiamond.sol#65-85) uses assembly - INLINE ASM (contracts/StakingDiamond.sol#68-70) - INLINE ASM (contracts/StakingDiamond.sol#73-84)
DiamondLoupeFacet.facets() (contracts/facets/DiamondLoupeFacet.sol#24-73) uses assembly

- INLINE ASM (contracts/facets/DiamondLoupeFacet.sol#65-67) - INLINE ASM (contracts/facets/DiamondLoupeFacet.sol#70-72)
  DiamondLoupeFacet.facetFunctionSelectors(address) (contracts/facets/DiamondLoupeFacet.sol#78-96) uses assembly - INLINE ASM (contracts/facets/DiamondLoupeFacet.sol#93-95)
  DiamondLoupeFacet.facetAddresses() (contracts/facets/DiamondLoupeFacet.sol#100-131) uses assembly - INLINE ASM (contracts/facets/DiamondLoupeFacet.sol#128-130)
  StakingFacet.claimTickets(uint256[],uint256[]) (contracts/facets/StakingFacet.sol#106-137)
  uses assembly - INLINE ASM (contracts/facets/StakingFacet.sol#128-130)
  TicketsFacet.safeTransferFrom(address,address,uint256,uint256,bytes) (contracts/facets/TicketsFacet.sol#61-90) uses assembly - INLINE ASM (contracts/facets/TicketsFacet.sol#81-83)
  TicketsFacet.safeBatchTransferFrom(address,address,uint256[],uint256[],bytes) (contracts/facets/TicketsFacet.sol#108-144) uses assembly - INLINE ASM (contracts/facets/TicketsFacet.sol#135-137)
  LibDiamond.diamondStorage() (contracts/libraries/LibDiamond.sol#27-32) uses assembly
- INLINE ASM (contracts/libraries/LibDiamond.sol#29-31)
  LibDiamond.enforceHasContractCode(address,string) (contracts/libraries/LibDiamond.sol#152-158) uses assembly - INLINE ASM (contracts/libraries/LibDiamond.sol#154-156)
  Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#assembly-usage

Pragma version^0.8.0 (contracts/Airrop.sol#2) allows old versions
Pragma version^0.8.0 (contracts/StakingDiamond.sol#2) allows old versions
Pragma version^0.8.0 (contracts/facets/DiamondCutFacet.sol#2) allows old versions  
Pragma version^0.8.0 (contracts/facets/DiamondLoupeFacet.sol#2) allows old versions
Pragma version^0.8.0 (contracts/facets/OwnershipFacet.sol#2) allows old versions  
Pragma version^0.8.0 (contracts/facets/StakingFacet.sol#2) allows old versions  
Pragma version^0.8.0 (contracts/facets/TicketsFacet.sol#2) allows old versions  
Pragma version^0.8.0 (contracts/interfaces/IDiamondCut.sol#2) allows old versions  
Pragma version^0.8.0 (contracts/interfaces/IDiamondLoupe.sol#2) allows old versions
Pragma version^0.8.0 (contracts/interfaces/IERC1155.sol#2) allows old versions
Pragma version^0.8.0 (contracts/interfaces/IERC1155Metadata_URI.sol#2) allows old versions
Pragma version^0.8.0 (contracts/interfaces/IERC1155TokenReceiver.sol#2) allows old versionsPragma version^0.8.0 (contracts/interfaces/IERC165.sol#2) allows old versions
Pragma version^0.8.0 (contracts/interfaces/IERC173.sol#2) allows old versions
Pragma version^0.8.0 (contracts/interfaces/IERC20.sol#2) allows old versions
Pragma version^0.8.0 (contracts/interfaces/IUniswapV2Pair.sol#2) allows old versions  
Pragma version^0.8.0 (contracts/libraries/AppStorage.sol#2) allows old versions
Pragma version^0.8.0 (contracts/libraries/LibDiamond.sol#2) allows old versions
Pragma version^0.8.0 (contracts/libraries/LibStrings.sol#2) allows old versions
solc-0.8.9 is not recommended for deployment
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity

Low level call in LibDiamond.initializeDiamondCut(address,bytes) (contracts/libraries/LibDiamond.sol#132-150): - (success,error) = \_init.delegatecall(\_calldata) (contracts/libraries/LibDiamond.sol#140)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls

TicketsFacet (contracts/facets/TicketsFacet.sol#24-232) should inherit from IERC1155Metadata_URI (contracts/interfaces/IERC1155Metadata_URI.sol#7-15)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-inheritance

Parameter Airdrop.airdropToken(address,address[],uint256[]).\_token (contracts/Airrop.sol#8) is not in mixedCase
Parameter Airdrop.airdropToken(address,address[],uint256[]).\_receivers (contracts/Airrop.sol#9) is not in mixedCase
Parameter Airdrop.airdropToken(address,address[],uint256[]).\_amounts (contracts/Airrop.sol#10) is not in mixedCase
Parameter Airdrop.airdropMatic(address[],uint256[]).\_receivers (contracts/Airrop.sol#18) is not in mixedCase
Parameter Airdrop.airdropMatic(address[],uint256[]).\_amounts (contracts/Airrop.sol#18) is not in mixedCase
Parameter DiamondCutFacet.diamondCut(IDiamondCut.FacetCut[],address,bytes).\_diamondCut (contracts/facets/DiamondCutFacet.sol#20) is not in mixedCase
Parameter DiamondCutFacet.diamondCut(IDiamondCut.FacetCut[],address,bytes).\_init (contracts/facets/DiamondCutFacet.sol#21) is not in mixedCase
Parameter DiamondCutFacet.diamondCut(IDiamondCut.FacetCut[],address,bytes).\_calldata (contracts/facets/DiamondCutFacet.sol#22) is not in mixedCase
Parameter DiamondLoupeFacet.facetFunctionSelectors(address).\_facet (contracts/facets/DiamondLoupeFacet.sol#78) is not in mixedCase
Parameter DiamondLoupeFacet.facetAddress(bytes4).\_functionSelector (contracts/facets/DiamondLoupeFacet.sol#137) is not in mixedCase
Parameter DiamondLoupeFacet.supportsInterface(bytes4).\_interfaceId (contracts/facets/DiamondLoupeFacet.sol#143) is not in mixedCase
Parameter OwnershipFacet.transferOwnership(address).\_newOwner (contracts/facets/OwnershipFacet.sol#8) is not in mixedCase
Parameter StakingFacet.frens(address).\_account (contracts/facets/StakingFacet.sol#17) is not in mixedCase
Parameter StakingFacet.bulkFrens(address[]).\_accounts (contracts/facets/StakingFacet.sol#25) is not in mixedCase
Parameter StakingFacet.updateAccounts(address[]).\_accounts (contracts/facets/StakingFacet.sol#38) is not in mixedCase
Parameter StakingFacet.updatePoolTokensRate(uint256).\_newRate (contracts/facets/StakingFacet.sol#48) is not in mixedCase
Parameter StakingFacet.migrateFrens(address[],uint256[]).\_stakers (contracts/facets/StakingFacet.sol#58) is not in mixedCase
Parameter StakingFacet.migrateFrens(address[],uint256[]).\_frens (contracts/facets/StakingFacet.sol#58) is not in mixedCase
Parameter StakingFacet.switchFrens(address,address).\_old (contracts/facets/StakingFacet.sol#68) is not in mixedCase
Parameter StakingFacet.switchFrens(address,address).\_new (contracts/facets/StakingFacet.sol#68) is not in mixedCase
Parameter StakingFacet.stakePoolTokens(uint256).\_poolTokens (contracts/facets/StakingFacet.sol#78) is not in mixedCase
Parameter StakingFacet.staked(address).\_account (contracts/facets/StakingFacet.sol#87) is not in mixedCase
Parameter StakingFacet.withdrawPoolStake(uint256).\_poolTokens (contracts/facets/StakingFacet.sol#98) is not in mixedCase
Parameter StakingFacet.claimTickets(uint256[],uint256[]).\_ids (contracts/facets/StakingFacet.sol#106) is not in mixedCase
Parameter StakingFacet.claimTickets(uint256[],uint256[]).\_values (contracts/facets/StakingFacet.sol#106) is not in mixedCase
Parameter StakingFacet.ticketCost(uint256).\_id (contracts/facets/StakingFacet.sol#139) is not in mixedCase
Parameter TicketsFacet.setMarketPlaceDiamond(address).\_marketPlaceDiamond (contracts/facets/TicketsFacet.sol#29) is not in mixedCase
Parameter TicketsFacet.setBaseURI(string).\_value (contracts/facets/TicketsFacet.sol#34) is
not in mixedCase
Parameter TicketsFacet.uri(uint256).\_id (contracts/facets/TicketsFacet.sol#42) is not in mixedCase
Parameter TicketsFacet.safeTransferFrom(address,address,uint256,uint256,bytes).\_from (contracts/facets/TicketsFacet.sol#62) is not in mixedCase
Parameter TicketsFacet.safeTransferFrom(address,address,uint256,uint256,bytes).\_to (contracts/facets/TicketsFacet.sol#63) is not in mixedCase
Parameter TicketsFacet.safeTransferFrom(address,address,uint256,uint256,bytes).\_id (contracts/facets/TicketsFacet.sol#64) is not in mixedCase
Parameter TicketsFacet.safeTransferFrom(address,address,uint256,uint256,bytes).\_value (contracts/facets/TicketsFacet.sol#65) is not in mixedCase
Parameter TicketsFacet.safeTransferFrom(address,address,uint256,uint256,bytes).\_data (contracts/facets/TicketsFacet.sol#66) is not in mixedCase
Parameter TicketsFacet.safeBatchTransferFrom(address,address,uint256[],uint256[],bytes).\_from (contracts/facets/TicketsFacet.sol#109) is not in mixedCase
Parameter TicketsFacet.safeBatchTransferFrom(address,address,uint256[],uint256[],bytes).\_to (contracts/facets/TicketsFacet.sol#110) is not in mixedCase
Parameter TicketsFacet.safeBatchTransferFrom(address,address,uint256[],uint256[],bytes).\_ids (contracts/facets/TicketsFacet.sol#111) is not in mixedCase
Parameter TicketsFacet.safeBatchTransferFrom(address,address,uint256[],uint256[],bytes).\_values (contracts/facets/TicketsFacet.sol#112) is not in mixedCase
Parameter TicketsFacet.safeBatchTransferFrom(address,address,uint256[],uint256[],bytes).\_data (contracts/facets/TicketsFacet.sol#113) is not in mixedCase
Parameter TicketsFacet.totalSupply(uint256).\_id (contracts/facets/TicketsFacet.sol#153) is
not in mixedCase
Parameter TicketsFacet.balanceOfAll(address).\_owner (contracts/facets/TicketsFacet.sol#158) is not in mixedCase
Parameter TicketsFacet.balanceOf(address,uint256).\_owner (contracts/facets/TicketsFacet.sol#171) is not in mixedCase
Parameter TicketsFacet.balanceOf(address,uint256).\_id (contracts/facets/TicketsFacet.sol#171) is not in mixedCase
Parameter TicketsFacet.balanceOfBatch(address[],uint256[]).\_owners (contracts/facets/TicketsFacet.sol#181) is not in mixedCase
Parameter TicketsFacet.balanceOfBatch(address[],uint256[]).\_ids (contracts/facets/TicketsFacet.sol#181) is not in mixedCase
Parameter TicketsFacet.setApprovalForAll(address,bool).\_operator (contracts/facets/TicketsFacet.sol#195) is not in mixedCase
Parameter TicketsFacet.setApprovalForAll(address,bool).\_approved (contracts/facets/TicketsFacet.sol#195) is not in mixedCase
Parameter TicketsFacet.isApprovedForAll(address,address).\_owner (contracts/facets/TicketsFacet.sol#206) is not in mixedCase
Parameter TicketsFacet.isApprovedForAll(address,address).\_operator (contracts/facets/TicketsFacet.sol#206) is not in mixedCase
Parameter TicketsFacet.migrateTickets(TicketsFacet.TicketOwner[]).\_ticketOwners (contracts/facets/TicketsFacet.sol#216) is not in mixedCase
Contract IERC1155Metadata_URI (contracts/interfaces/IERC1155Metadata_URI.sol#7-15) is not in CapWords
Function IUniswapV2Pair.DOMAIN_SEPARATOR() (contracts/interfaces/IUniswapV2Pair.sol#32) is
not in mixedCase
Function IUniswapV2Pair.PERMIT_TYPEHASH() (contracts/interfaces/IUniswapV2Pair.sol#34) is not in mixedCase
Function IUniswapV2Pair.MINIMUM_LIQUIDITY() (contracts/interfaces/IUniswapV2Pair.sol#53) is not in mixedCase
Parameter LibDiamond.setContractOwner(address).\_newOwner (contracts/libraries/LibDiamond.sol#36) is not in mixedCase
Parameter LibDiamond.diamondCut(IDiamondCut.FacetCut[],address,bytes).\_diamondCut (contracts/libraries/LibDiamond.sol#55) is not in mixedCase
Parameter LibDiamond.diamondCut(IDiamondCut.FacetCut[],address,bytes).\_init (contracts/libraries/LibDiamond.sol#56) is not in mixedCase
Parameter LibDiamond.diamondCut(IDiamondCut.FacetCut[],address,bytes).\_calldata (contracts/libraries/LibDiamond.sol#57) is not in mixedCase
Parameter LibDiamond.addFunctions(address,bytes4[]).\_facetAddress (contracts/libraries/LibDiamond.sol#75) is not in mixedCase
Parameter LibDiamond.addFunctions(address,bytes4[]).\_functionSelectors (contracts/libraries/LibDiamond.sol#75) is not in mixedCase
Parameter LibDiamond.replaceFunctions(address,bytes4[]).\_facetAddress (contracts/libraries/LibDiamond.sol#91) is not in mixedCase
Parameter LibDiamond.replaceFunctions(address,bytes4[]).\_functionSelectors (contracts/libraries/LibDiamond.sol#91) is not in mixedCase
Parameter LibDiamond.removeFunctions(address,bytes4[]).\_facetAddress (contracts/libraries/LibDiamond.sol#108) is not in mixedCase
Parameter LibDiamond.removeFunctions(address,bytes4[]).\_functionSelectors (contracts/libraries/LibDiamond.sol#108) is not in mixedCase
Parameter LibDiamond.initializeDiamondCut(address,bytes).\_init (contracts/libraries/LibDiamond.sol#132) is not in mixedCase
Parameter LibDiamond.initializeDiamondCut(address,bytes).\_calldata (contracts/libraries/LibDiamond.sol#132) is not in mixedCase
Parameter LibDiamond.enforceHasContractCode(address,string).\_contract (contracts/libraries/LibDiamond.sol#152) is not in mixedCase
Parameter LibDiamond.enforceHasContractCode(address,string).\_errorMessage (contracts/libraries/LibDiamond.sol#152) is not in mixedCase
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions

Variable DiamondLoupeFacet.facetFunctionSelectors(address)._facetFunctionSelectors (contracts/facets/DiamondLoupeFacet.sol#78) is too similar to IDiamondLoupe.facetFunctionSelectors(address).facetFunctionSelectors_ (contracts/interfaces/IDiamondLoupe.sol#22)
Variable StakingFacet.stakePoolTokens(uint256)._poolTokens (contracts/facets/StakingFacet.sol#78) is too similar to StakingFacet.staked(address).poolTokens_ (contracts/facets/StakingFacet.sol#91)
Variable StakingFacet.withdrawPoolStake(uint256)._poolTokens (contracts/facets/StakingFacet.sol#98) is too similar to StakingFacet.staked(address).poolTokens_ (contracts/facets/StakingFacet.sol#91)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#variable-names-are-too-similar

**\*\*\*\***\***\*\*\*\***MYTHRIL\***\*\*\*\*\***\*\*\*\*\***\*\*\*\*\***

- [StakingFacet.sol](contracts/facets/StakingFacet.sol)
- [TicketsFacet.sol](contracts/facets/TicketsFacet.sol)
- [Airdop.sol](contracts/Airdop.sol)
- [StakingDiamond.sol](contracts/StakingDiamond.sol)
- [AppStorage.sol](contracts/libraries/AppStorage.sol)
- [LibStrings.sol](contracts/libraries/LibStrings.sol)

on AIrdrop There should be a maximum of transfers. requirement on both functions
replace the transfer function with low level call
on airdroo matic you have to check the value obtained out of the clow level call function
