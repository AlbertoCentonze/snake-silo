import boa

def test_deposit(admin, alice, silo, silo_asset):
    with boa.env.prank(admin):
        silo_asset.mint(alice, 1000)

    with boa.env.prank(alice):
        silo_asset.approve(silo.address, 1000)
        silo.deposit(silo_asset, alice, 1000)

def test_withdraw(admin, alice, silo, silo_asset, collat):
    with boa.env.prank(admin):
        silo_asset.mint(alice, 1000)

    with boa.env.prank(alice):
        silo_asset.approve(silo.address, 1000)
        silo.deposit(silo_asset, alice, 1000)
        collat.approve(silo.address, 1000)
        silo.withdraw(silo_asset, alice, 1000)

def test_borrow(admin, alice, bob, silo, silo_asset, debt):
    with boa.env.prank(admin):
        silo_asset.mint(alice, 1000)

    with boa.env.prank(alice):
        silo_asset.approve(silo.address, 1000)
        silo.deposit(silo_asset, alice, 1000)

    with boa.env.prank(bob):
        silo.borrow(silo_asset, bob, 100)