import boa
import pytest

boa.env.enable_fast_mode()


@pytest.fixture(scope="session")
def alice():
    return boa.env.generate_address("alice")


@pytest.fixture(scope="session")
def bob():
    return boa.env.generate_address("bob")


@pytest.fixture(scope="session")
def admin():
    return boa.env.generate_address("admin")


@pytest.fixture(scope="session")
def debt(admin, silo, silo_asset):
    with boa.env.prank(admin):
        debt = boa.load("contracts/ShareDebtToken.vy", "debt", "debt", silo.address, silo_asset.address)
        boa.env.alias(debt.address, "debt")
        return debt


@pytest.fixture(scope="session")
def collat(admin, silo, silo_asset):
    with boa.env.prank(admin):
        collat = boa.load("contracts/ShareCollateralToken.vy", "collateral", "coll", silo.address, silo_asset.address)
        boa.env.alias(collat.address, "collat")
        return collat



@pytest.fixture(scope="session")
def silo_asset(admin):
    with boa.env.prank(admin):
        silo_asset = boa.load("./tests/contracts/MockERC20.vy", "MockERC20", "MOCK", 10, "Whatever", "Whatever")
        boa.env.alias(silo_asset.address, "silo_asset")
        return silo_asset



@pytest.fixture(scope="session")
def silo(admin, silo_asset):
    with boa.env.prank(admin):
        silo = boa.load("contracts/Silo.vy", silo_asset.address)
        boa.env.alias(silo.address, "collat")
        return silo


@pytest.fixture(autouse=True)
def setup(admin, silo, silo_asset, collat, debt):
    with boa.env.prank(admin):
        silo.init_asset(collat.address, debt.address, silo_asset.address, False);
    with boa.env.prank(silo.address):
        collat.set_minter(admin, True)
        debt.set_minter(admin, True)
    yield

boa.env