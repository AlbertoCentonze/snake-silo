# SILO: Not using repository

struct AssetStorage:
    collateral_token: ShareToken
    debt_token: ShareToken
    total_deposits: uint256 
    total_borrow_amount: uint256 

# TODO make imports work to remove redundant interfaces
interface ShareToken:
    def mint(to: address, amount: uint256) -> bool: nonpayable
    def burn(_from: address, amount: uint256) -> bool: nonpayable
    def totalSupply() -> uint256: view
    def balanceOf(_owner: address) -> uint256: view

@external
def init_pepository(repository: address): 
    pass

# VYPER: string upperbound did not exist in solidity implementation
@external
def create_share_collateral_token(name: String[100], symbol: String[100], asset: address) -> ShareToken:
    # SILO: Not using repository but only the silo should be able to call this function

    return convert(ShareCollateralToken(_name, _symbol, msg.sender, _asset), ShareToken)
 
# VYPER: string upperbound did not exist in solidity implementation
@external
def create_share_debt_token(name: String[100], symbol: String[100], asset: address) -> ShareToken:
    # SILO: Not using repository but only the silo should be able to call this function

    return convert(ShareDebtToken(_name, _symbol, msg.sender, _asset), ShareToken)

# SILO: Removed ping function