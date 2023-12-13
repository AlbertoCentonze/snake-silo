from vyper.interfaces import ERC20
import Silo as ISilo

implements: ERC20

# TODO add variables scopes and mutability (public, constant, immutable)
MINIMUM_SHARE_AMOUNT: uint256

silo: public(ISilo)
asset: public(address)
_decimals: public(uint8)


# TODO: check silo permissions with this
#         if (msg.sender != address(silo)) revert OnlySilo()

@external
def __init__(silo: address, asset: address):
    self.silo = ISilo(_silo)
    self.asset = _asset
    self._decimals = IERC20Metadata(asset).decimals()

    # VYPER: MINIMUM_SHARE_AMOUNT has to be initialized in the constructor
    MINIMUM_SHARE_AMOUNT = 1e5

@external 
def mint(account: address , amount: uint256): 
    # SILO: should be silo gated
    self._mint(_account, _amount)

@external 
def burn(account: address , amount: uint256): 
    # SILO: should be silo gated
    self._burn(_account, _amount)

@view
@external 
def symbol() -> (String[6]):
    return ERC20.symbol()

@view
@external
def decimals() -> (uint8):
        return _decimals

@internal
def _after_token_transfer(sender: address , recipient: address, _: uint256):
        if self._is_transfer(sender, recipient):
            return

        total: uint256 = totalSupply()
        if total != 0 and total < MINIMUM_SHARE_AMOUNT:
            raise "Minimum Share Requirement"

@internal 
def notify_about_transfer(from_: address, to: address, amount: uint256): 
    # SILO: Skipping this if untill silo repo is implemented
    pass 


@internal
def _is_transfer(sender: address, recipient: address) -> (bool):
        return sender != address(0) and recipient != address(0)