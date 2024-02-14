import boa
import pytest

boa.env.enable_fast_mode()

@pytest.fixture(scope="module")
def accounts():
    return [boa.env.generate_address() for _ in range(10)]


@pytest.fixture(scope="module")
def admin():
    return boa.env.generate_address()