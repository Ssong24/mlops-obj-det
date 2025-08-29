import pytest

def pytest_configure(config):
    config.addinivalue_line("markers", "smoke: mart test as smoke test")

# Silence Prefect logs during pytest runs
#@pytest.fixture(autouse=True, scope="session")
#def disable_prefect_console_logging():
#    prefect.logging.disable_run_logger()

