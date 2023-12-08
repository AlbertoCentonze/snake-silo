# version 0.3.10
from vyper.interfaces import ERC20

main_asset: public(address)

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
def __init__():
    pass

@internal
def is_solvent() -> bool:
    # TODO implement this later
    return True 

@internal
def _borrow_possible(asset: address, borrower: address) -> bool:
    # SILO: This function was simplified due the nature of this implementation
    return self.asset_storage[asset].collateral_token.balanceOf(borrower) == 0

@view
@internal
def _liquidity(asset: address) -> uint256:
    # SILO: this function doesn't need to account for collateral only deposits
    return ERC20(asset).balanceOf(self)


@internal
def _accrue_interest(asset: address):
    pass

@external
def deposit(asset: address, receiver: address, amount: uint256) -> (uint256, uint256):
    # SILO: changes were made to the arguments since there's no router
    # SILO: changes were made to the arguments since there's no collateral only deposits
    # SILO: changes were made to the function visibility to reduce complexity

    self._accrue_interest(asset)
    
    # TODO add asset deposit validation

    state: AssetStorage = self.asset_storage[asset]

    collateral_share: uint256 = self.amount_to_share(amount, state.total_deposits, state.collateral_token.totalSupply())
    state.total_deposits += amount
    state.collateral_token.mint(receiver, collateral_share)

    ERC20(asset).transferFrom(msg.sender, self, amount)

    return amount, collateral_share

@external
def withdraw(asset: address, receiver: address, amount: uint256) -> (uint256, uint256):
    # SILO: changes were made to the arguments since there's no router
    # SILO: changes were made to the arguments since there's no collateral only deposits
    # SILO: changes were made to the function visibility to reduce complexity

    self._accrue_interest(asset)

    # TODO add asset withdraw validation

    if amount == 0:
        return 0, 0

    state: AssetStorage = self.asset_storage[asset]

    burned_share: uint256 = self.amount_to_share_round_up(amount, state.total_deposits, state.collateral_token.totalSupply())

    asset_total_deposits: uint256 = state.total_deposits
    share_token: ShareToken = state.collateral_token
    available_liquidity: uint256 = ERC20(asset).balanceOf(self)


    if asset_total_deposits < amount:
        raise "Not Enough Deposits" # TODO: check whether this condition is redundant with the collateral only option

    asset_total_deposits -=  amount

    if available_liquidity < amount:
        raise "Not Enough Liquidity"

    state.total_deposits = asset_total_deposits
    share_token.burn(msg.sender, burned_share)
    ERC20(asset).transfer(receiver, amount)

    if not self.is_solvent():
        raise "Insolvent"
    return amount, burned_share

@external
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

    ERC20(asset).transfer(receiver, amount)

    # SILO: removed validate borrow after logic here

    return amount, debt_share

@external
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
    ERC20(asset).transferFrom(msg.sender, self, amount)

    state.total_borrow_amount -= amount
    state.debt_token.burn(borrower, repaid_share)

    return repaid_amount, repaid_share


###########  HELPER FUNCTIONS  ###########

# SILO: This functions were part of a soldity library

@pure
@internal
def amount_to_share(amount: uint256, totalAmount: uint256, totalShares: uint256) -> uint256:
    if totalShares == 0 or totalAmount == 0:
        return amount

    result: uint256 = amount * totalShares / totalAmount

    if result == 0 and amount != 0:
        raise "ZeroShares"

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