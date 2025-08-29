import sys, os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

from app.flow import mlops_flow
import pytest

@pytest.mark.smoke
def test_smoke_pipeline():
    """
    Run the full Prefect flow for a mini smoke test.
    """

    mlops_flow()
    # if no exception is raised, test passes
