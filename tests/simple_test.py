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

def test_borrow(admin, alice, bob, silo, silo_asset):
    with boa.env.prank(admin):
        silo_asset.mint(alice, 1000)

    with boa.env.prank(alice):
        silo_asset.approve(silo.address, 1000)
        silo.deposit(silo_asset, alice, 1000)

    with boa.env.prank(bob):
        silo.borrow(silo_asset, bob, 100)

def test_repay(admin, alice, bob, silo, silo_asset):
    boa.env.alias("0xC6Acb7D16D51f72eAA659668F30A40d87E2E0551", "test-alias")
    boa.env.alias("0x0000000000000000000000000000000000000000", "0x0") 
    boa.env.alias("0x78548820b365886d05009F1127bf553603E5A836", "collat")
    with boa.env.prank(admin):
        silo_asset.mint(alice, 1000)

    with boa.env.prank(alice):
        silo_asset.approve(silo.address, 1000)
        silo.deposit(silo_asset, alice, 1000)

    with boa.env.prank(bob):
        silo.borrow(silo_asset, bob, 100)
        silo_asset.approve(silo.address, 100)
        silo.repay(silo_asset, bob, 100)
