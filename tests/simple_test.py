import boa

DEPOSIT_AMOUNT = int(1000e18)
BORROW_AMOUNT = int(100e18)

def test_deposit(admin, alice, silo, silo_asset):
    with boa.env.prank(admin):
        silo_asset.mint(alice, DEPOSIT_AMOUNT)

    with boa.env.prank(alice):
        silo_asset.approve(silo.address, DEPOSIT_AMOUNT)
        silo.deposit(silo_asset, alice, DEPOSIT_AMOUNT)

def test_withdraw(admin, alice, silo, silo_asset, collat):
    with boa.env.prank(admin):
        silo_asset.mint(alice, DEPOSIT_AMOUNT)

    with boa.env.prank(alice):
        silo_asset.approve(silo.address, DEPOSIT_AMOUNT)
        silo.deposit(silo_asset, alice, DEPOSIT_AMOUNT)
        collat.approve(silo.address, DEPOSIT_AMOUNT)
        silo.withdraw(silo_asset, alice, DEPOSIT_AMOUNT)

def test_borrow(admin, alice, bob, silo, silo_asset):
    with boa.env.prank(admin):
        silo_asset.mint(alice, DEPOSIT_AMOUNT)

    with boa.env.prank(alice):
        silo_asset.approve(silo.address, DEPOSIT_AMOUNT)
        silo.deposit(silo_asset, alice, DEPOSIT_AMOUNT)

    with boa.env.prank(bob):
        silo.borrow(silo_asset, bob, BORROW_AMOUNT)

def test_repay(admin, alice, bob, silo, silo_asset):
    with boa.env.prank(admin):
        silo_asset.mint(alice, DEPOSIT_AMOUNT)

    with boa.env.prank(alice):
        silo_asset.approve(silo.address, DEPOSIT_AMOUNT)
        silo.deposit(silo_asset, alice, DEPOSIT_AMOUNT)

    with boa.env.prank(bob):
        silo.borrow(silo_asset, bob, BORROW_AMOUNT)
        silo_asset.approve(silo.address, BORROW_AMOUNT)
        silo.repay(silo_asset, bob, BORROW_AMOUNT)
