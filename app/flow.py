from prefect import flow, task
import subprocess
import requests
import time
import os

# ---------------------------
# Tasks
# ---------------------------

@task
def run_training():
    """
    Trigger YOLO training via docker-compose.
    """
    print("Starting YOLO training...")
    subprocess.run(["docker", "compose", "run", "--rm", "train"], check=True)
    print("Training finished.")
    return True

@task
def wait_for_infer():
    """
    Wait for FastAPI inference server to be ready.
    """
    print("Waiting for FastAPI inference server...")
    url = "http://localhost:8000/predict"
    for i in range(20):  # wait up to ~20 seconds
        try:
            r = requests.get("http://localhost:8000/docs")
            if r.status_code == 200:
                print("FastAPI server is ready!")
                return True
        except:
            pass
        time.sleep(1)
    raise RuntimeError("FastAPI server not ready after waiting.")

@task
def test_inference():
    """
    Run a test inference on a sample image.
    """
    img_path = "datasets/coco128/images/train2017/000000000283.jpg"
    if not os.path.exists(img_path):
        raise FileNotFoundError(f"{img_path} does not exist")

    files = {"file": open(img_path, "rb")}
    r = requests.post("http://localhost:8000/predict", files=files)
    print("Inference result:", r.json())
    return r.json()

# ---------------------------
# Flow
# ---------------------------

@flow(name="MLOps Mini Pipeline")
def mlops_flow():
    run_training()
    wait_for_infer()
    test_inference()

if __name__ == "__main__":
    mlops_flow()
