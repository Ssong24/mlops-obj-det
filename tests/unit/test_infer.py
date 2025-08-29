import pytest
import requests
import os

def test_inference_endpoint():
    """
    Test FastAPI /predict endpoint with a sample image.
    """
    img_path = "datasets/coco128/images/train2017/000000000283.jpg"
    assert os.path.exists(img_path), "Sample image not found"

    files = {"file": open(img_path, "rb")}
    r = requests.post("http://localhost:8000/predict", files=files)
    assert r.status_code == 200, f"Inference failed: {r.text}"
    data = r.json()
    assert "boxes" in data, "No boxes returned"
    assert "labels" in data, "No labels returned"
    assert "scores" in data, "No scores returned"