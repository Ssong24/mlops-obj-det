# Unit test
## Goal
Test individual pieces of code independently. For your project, typical unit tests include:

- Training function (yolo train)
    - Check that the function runs without errors for a few epochs on a tiny dataset.

- MLflow logging
    - Ensure metrics and artifacts are correctly logged.

- Prefect tasks
    - Test that tasks (run_training(), test_inference()) can execute independently.


# Smoke test
## Goal
Quick, end-to-end checks to make sure the pipeline "runs without crashing".
- Run all tasts in Prefect flow with tiny settings (like 1 epoch, small dataset).
- Ensure MLflow logging and FastAPI prediction work.

