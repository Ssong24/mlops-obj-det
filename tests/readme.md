
# Test Suite for MLOps Mini Pipeline

This folder contains unit and smoke tests for the YOLO-based MLOps pipeline, including training, inference, MLflow logging, and Prefect flow execution.

---

## Unit Tests

### Purpose

Unit tests verify that individual components of the pipeline work correctly.  

### What to Check

- **YOLO Training**  
  Ensure that the model can start training without errors.
  ```bash
  docker compose run --rm train
  ```

- **MLflow Logging**
  Confirm that MLflow logs the training run.
  Access the UI at `http://localhost:5001/`

### Run Unit Tests

```bash
pytest -s tests/unit/
```

---

## Smoke Tests

### Purpose

Smoke tests verify that the **entire pipeline** runs correctly from end to end.

### What to Check

* **Prefect Flow Execution**
  Confirm that the `mlops_flow()` works as expected:

  1. `run_training()` - trains the YOLO model.
  2. `wait_for_infer()` - waits for the FastAPI inference server to be ready.
  3. `test_inference()` - sends a sample image to the `/predict` endpoint and checks the prediction results.

### Run Smoke Tests

```bash
pytest -m smoke
```

