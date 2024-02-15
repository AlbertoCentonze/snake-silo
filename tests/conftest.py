import boa
import pytest

boa.env.enable_fast_mode()

@pytest.fixture(scope="session")
def accounts():
    return [boa.env.generate_address() for _ in range(10)]

@pytest.fixture(scope="session")
def alice(accounts):
    return accounts[0]

@pytest.fixture(scope="session")
def bob(accounts):
    return accounts[1]

@pytest.fixture(scope="session")
def admin():
    return boa.env.generate_address()

@pytest.fixture(scope="session")
def debt(admin):
    with boa.env.prank(admin):
        return boa.load("./tests/contracts/MockERC20.vy", "debt", "MOCK", 0, "Whatever", "Whatever")

@pytest.fixture(scope="session")
def collat(admin):
    with boa.env.prank(admin):
        return boa.load("./tests/contracts/MockERC20.vy", "collat", "MOCK", 0, "Whatever", "Whatever")

@pytest.fixture(scope="session")
def silo_asset(admin):
    with boa.env.prank(admin):
        return boa.load("./tests/contracts/MockERC20.vy", "MockERC20", "MOCK", 10, "Whatever", "Whatever")

@pytest.fixture(scope="session")
def silo(admin, silo_asset, debt, collat):
    with boa.env.prank(admin):
        silo = boa.load("contracts/Silo.vy", silo_asset.address)
        collat.set_minter(silo.address, True)
        debt.set_minter(silo.address, True)
        silo.init_asset(collat.address, debt.address, silo_asset.address, False);
        return silo