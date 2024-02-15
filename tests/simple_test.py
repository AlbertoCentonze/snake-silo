import boa

def test_deposit(admin, alice, silo, silo_asset) -> None:
    with boa.env.prank(admin):
        silo_asset.mint(alice, 1000)

    with boa.env.prank(alice):
        silo_asset.approve(silo.address, 1000)
        silo.deposit(silo_asset, alice, 1000)