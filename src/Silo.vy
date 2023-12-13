# version 0.3.10
from vyper.interfaces import ERC20

silo_asset: public(address)
silo_repository: SiloRepository

# SILO: this should go in the repository
bridge_assets: public(address[2])

# VYPER: in solidity the upperbound depends on solidity max array size
_all_silo_assets: DynArray[address, 100]

interface SiloRepository:
    def tokens_factory() -> TokensFactory: nonpayable

interface TokensFactory:
    def create_share_collateral_token(name: String[100], symbol: String[100], asset: address) -> ShareToken: nonpayable
    def create_share_debt_token(name: String[100], symbol: String[100], asset: address) -> ShareToken: nonpayable

interface ShareToken:
    def mint(to: address, amount: uint256) -> bool: nonpayable
    def burn(_from: address, amount: uint256) -> bool: nonpayable
    def totalSupply() -> uint256: view
    def balanceOf(_owner: address) -> uint256: view
    
struct AssetStorage:
    collateral_token: ShareToken
    debt_token: ShareToken
    total_deposits: uint256 
    total_borrow_amount: uint256 

asset_storage: public(HashMap[address, AssetStorage])

@external
def __init__(silo_asset: address):
    self.silo_asset = silo_asset

# VYPER: Exposing internal function to obtain the equivalent of a public solidity method
@external
def is_solvent(user: address) -> bool:
    return self._is_solvent(user)

@internal
def _is_solvent(user: address) -> bool:
    # TODO implement this later
    return True 

@internal
def _borrow_possible(asset: address, borrower: address) -> bool:
    # SILO: This function was simplified due the nature of this implementation
    return self.asset_storage[asset].collateral_token.balanceOf(borrower) == 0

@internal
def _deposit_possible(asset: address, depositor: address) -> bool:
    # TODO implement this later
    return True

@view
@internal
def _liquidity(asset: address) -> uint256:
    # SILO: this function doesn't need to account for collateral only deposits
    return ERC20(asset).balanceOf(self)


@internal
def _accrue_interest(asset: address):
    # TODO implement this later
    pass

@internal 
def _init_asset(tokens_factory: TokensFactory, asset: address, is_bridge_asset: bool):
    # SILO: not generating share names

    state: AssetStorage = self.asset_storage[asset]

    state.collateral_token = tokens_factory.create_share_collateral_token("name placeholder", "symbol placeholder", asset)

    # SILO: skipping collateral only token

    state.debt_token = tokens_factory.create_share_debt_token("name placeholder", "symbol placeholder", asset)

    self._all_silo_assets.append(asset)

    # SILO: skipping interest data

@internal
def _init_asset_tokens():
    # SILO: Not using token factory so putting empty(address) where necessary
    tokens_factory: TokensFactory = self.silo_repository.tokens_factory() 
    
    if self.asset_storage[self.silo_asset].collateral_token.address == empty(address):
        self._init_asset(tokens_factory, self.silo_asset, False)

    for i in range(2): # SILO: capping bridge assets to 2
        bridge_asset: address = self.bridge_assets[i]
        if self.asset_storage[bridge_asset].collateral_token.address == empty(address):
            self._init_asset(tokens_factory, bridge_asset, True)
        else:
            # SILO: no interest data
            pass


@external
@nonreentrant("lock")
def deposit(asset: address, receiver: address, amount: uint256) -> (uint256, uint256):
    # SILO: changes were made to the arguments since there's no router
    # SILO: changes were made to the arguments since there's no collateral only deposits
    # SILO: changes were made to the function visibility to reduce complexity
    # TODO add validateMaxDepositsAfter modifier in an idiomatic way

    self._accrue_interest(asset)
    
    # SILO : only possible depositor is msg.sender since no router
    if not self._deposit_possible(asset, msg.sender):
        raise "Deposit Not Possible"

    state: AssetStorage = self.asset_storage[asset]

    # SILO: No need to assign return value since I return amount directly

    # SILO: removed collateral only logic
    collateral_share: uint256 = self.amount_to_share(amount, state.total_deposits, state.collateral_token.totalSupply())
    state.total_deposits += amount
    state.collateral_token.mint(receiver, collateral_share)

    ERC20(asset).transferFrom(msg.sender, self, amount, default_return_value=True)

    return amount, collateral_share

@external
@nonreentrant("lock")
def withdraw(asset: address, receiver: address, amount: uint256) -> (uint256, uint256):
    # SILO: changes were made to the arguments since there's no router
    # SILO: changes were made to the arguments since there's no collateral only deposits
    # SILO: changes were made to the function visibility to reduce complexity
    # TODO add onlyExistingAsset modifier in an idiomatic way

    self._accrue_interest(asset)

    # SILO: start of _withdrawAsset logic
    # SILO: start of _getWithdrawAssetData logic
    # SILO: ignoring the collateral_only possibility
    state: AssetStorage = self.asset_storage[asset]

    asset_total_deposits: uint256 = state.total_deposits
    share_token: ShareToken = state.collateral_token
    available_liquidity: uint256 = ERC20(asset).balanceOf(self)
    # SILO end of _getWithdrawAssetData logic

    # SILO: ignoring the max arugment possibility (check #6)
    burned_share: uint256 = self.amount_to_share_round_up(amount, state.total_deposits, state.collateral_token.totalSupply())
    # SILO: _assetAmount is amount here, no need to return it like in soldiity
    
    if amount == 0:
        return 0, 0

    if asset_total_deposits < amount:
        raise "Not Enough Deposits"
    
    # SILO: Can't make this unchecked since there's no access to inilne assembly in vyper
    asset_total_deposits -=  amount

    # TODO add liquidation fee logic here

    if available_liquidity < amount:
        raise "Not Enough Liquidity"
    
    # SILO: state already accessed in an inlined function call

    # SILO:  ignroing the collateral only possibility

    state.total_deposits = asset_total_deposits

    # SILO: only depositor is msg.sender since no router
    share_token.burn(msg.sender, burned_share)
    ERC20(asset).transfer(receiver, amount, default_return_value=True)
    # SILO: end of _withdrawAsset logic

    # SILO: only depositor is msg.sender since no router
    if not self._is_solvent(msg.sender):
        raise "Not Solvent"
    return amount, burned_share

@external
@nonreentrant("lock")
def borrow(asset: address, receiver: address, amount: uint256) -> (uint256, uint256):
    # SILO: changes were made to the arguments since there's no router
    # SILO: changes were made to the function visibility to reduce complexity

    self._accrue_interest(asset)

    # TODO add asset borrow validation

    if not self._borrow_possible(asset, msg.sender):
        raise "Borrow Not Possible"
    
    if not self._liquidity(asset) < amount:
        raise "Not Enough Liquidity"

    state: AssetStorage = self.asset_storage[asset]

    # SILO: removed entry fee logic here

    debt_share: uint256 = self.amount_to_share_round_up(amount, state.total_borrow_amount, state.debt_token.totalSupply())
    
    state.total_borrow_amount += amount

    # SILO: removed protocol fees logic here

    state.debt_token.mint(receiver, debt_share)

    ERC20(asset).transfer(receiver, amount, default_return_value=True)

    # SILO: removed validate borrow after logic here

    return amount, debt_share

@external
@nonreentrant("lock")
def repay(asset: address, borrower: address, amount: uint256) -> (uint256, uint256):
    # SILO: changes were made to the arguments since there's no router
    # SILO: changes were made to the function visibility to reduce complexity
    
    self._accrue_interest(asset)

    state: AssetStorage = self.asset_storage[asset]

    # SILO: this part is done in _calculateDebtAmountAndShare
    borrower_debt_share: uint256 = state.debt_token.balanceOf(borrower)
    debt_token_total_supply: uint256  = state.debt_token.totalSupply()
    total_borrowed: uint256 = state.total_borrow_amount
    max_amount: uint256 = self.share_to_amount_round_up(borrower_debt_share, total_borrowed, debt_token_total_supply)

    # SILO: This is supposed to be the value of `amount` returned by _calculateDebtAmountAndShare
    repaid_amount: uint256 = amount
    # SILO: This is supposed to be the value of `reapay_share` returned by _calculateDebtAmountAndShare
    repaid_share: uint256 = 0

    if amount >= max_amount:
        repaid_amount = max_amount
        repaid_share = borrower_debt_share
    else:
        repaid_share = self.amount_to_share(amount, total_borrowed, debt_token_total_supply)

    # SILO: end of the part done in _calculateDebtAmountAndShare
    
    if repaid_share == 0:
        raise "Unexpected Empty Return"

    # SILO: msg.sender is the only repayer possible since no router
    ERC20(asset).transferFrom(msg.sender, self, amount, default_return_value=True)

    state.total_borrow_amount -= amount
    state.debt_token.burn(borrower, repaid_share)

    return repaid_amount, repaid_share


###########  HELPER FUNCTIONS  ###########

# SILO: This functions were part of the EasyMath soldity library

@pure
@internal
def amount_to_share(amount: uint256, totalAmount: uint256, totalShares: uint256) -> uint256:
    if totalShares == 0 or totalAmount == 0:
        return amount

    result: uint256 = amount * totalShares / totalAmount

    if result == 0 and amount != 0:
        raise "Zero Shares"

    return result

@pure
@internal
def amount_to_share_round_up(amount: uint256, total_amount: uint256, total_shares: uint256) -> uint256:
    if total_shares == 0 or total_amount == 0:
        return amount

    numerator: uint256 = amount * total_shares
    result: uint256 = numerator / total_amount
    
    # Round up if there's a remainder
    if numerator % total_amount != 0:
        result += 1

    return result

@pure
@internal
def share_to_amount_round_up(share: uint256, total_amount: uint256, total_shares: uint256) -> uint256:
    if total_shares == 0 or total_amount == 0:
        return 0

    numerator: uint256 = share * total_amount
    result: uint256 = numerator / total_shares
    
    # Round up if there's a remainder
    if numerator % total_shares != 0:
        result += 1

    return result

# using forceApprove instead of safeApprove since it has been deprecated by oz
@internal
def forceApprove(asset: ERC20, spender: address, amount: uint256):
    asset.approve(spender, 0, default_return_value=True)
    asset.approve(spender, amount, default_return_value=True)
