import boa

def test_deposit(admin, accounts) -> None:
    with boa.env.prank(admin):
        mockERC20 = boa.load("./tests/contracts/MockERC20.vy", "MockERC20", "MOCK", 10, "Whatever", "Whatever")
        collat = boa.load("./tests/contracts/MockERC20.vy", "collat", "MOCK", 1, "Whatever", "Whatever")
        debt = boa.load("./tests/contracts/MockERC20.vy", "debt", "MOCK", 0, "Whatever", "Whatever")
        silo = boa.load("contracts/Silo.vy", mockERC20.address)
        mockERC20.mint(accounts[0], 1000);
        collat.set_minter(silo.address, True)
        debt.set_minter(silo.address, True)
        collat.mint(accounts[0], 1000)
        silo.init_asset(collat.address, debt.address, mockERC20.address, False);


    with boa.env.prank(accounts[0]):
        mockERC20.approve(silo.address, 1000)
        silo.deposit(mockERC20.address, accounts[0], 1000)

