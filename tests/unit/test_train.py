import pytest
import subprocess

def test_training_runs():
    """
    Run YOLO training for 1 epoch on tiny dataset to ensure no erros.
    """

    cmd = [
        "docker", "compose", "run", "--rm", "train"
    ]

    # optionally, override epochs for faster test
    result = subprocess.run(cmd, capture_output=True, text=True)
    assert result.returncode == 0, f"Training failed: {result.stderr}"