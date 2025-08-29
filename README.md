# YOLOv8 Object Detection MLOps Pipeline

A mini MLOps project demonstrating end-to-end object detection using **YOLOv8**, managed with **Prefect** workflows, tracked with **MLflow**, and served via **FastAPI** in Docker containers.  

---

## **Project Overview**

This project implements a 2D object detection pipeline with the following features:

- Train YOLOv8 model on a small dataset (`coco128`) or custom datasets.
- Track experiments, metrics, and model artifacts with MLflow.
- Orchestrate training, evaluation, and deployment using Prefect flows.
- Serve predictions via a FastAPI inference API in Docker.
- Unit tests and smoke tests ensure correctness of pipeline steps.

---

## **Project Structure**

```yaml

project/
├─ app/                
│   ├─ __init__.py
│   ├─ main.py         # FastAPI server
│   └─ flow.py         # Prefect MLOps flow
├─ data/               # Dataset configs (YAML)
│   └─ coco128.yaml
├─ datasets/           
│   └─ coco128/
├─ docker/             # Dockerfiles for training and inference
│   ├─ Dockerfile.train
│   └─ Dockerfile.infer
├─ mlflow/             # MLflow DB and artifacts
│   ├─ db/
│   └─ mlartifacts/
├─ tests/              # Unit & smoke tests
│   ├─ unit/
│   └─ smoke/
├─ docker-compose.yml
├─ requirements.txt    
└─ README.md

```

---

## **Setup Instructions**

### 1. Clone repository

```bash
git clone <your_repo_url>
cd project
```

### 2. Create Conda environment

```bash
conda create -n mlops-objdet python=3.10 -y
conda activate mlops-objdet
pip install -r requirements.txt
```

### 3. Build Docker images

```bash
# Training image
docker build -t yolo-train -f docker/Dockerfile.train .

# Inference image
docker build -t yolo-infer -f docker/Dockerfile.infer .
```

### 4. Start MLflow server (Docker Compose)

```bash
docker-compose up -d mlflow
# MLflow UI available at http://localhost:5001
```

---

## **Running the Pipeline**

### 1. Run Prefect MLOps flow

```bash
python app/flow.py
```

* This will trigger the training pipeline using YOLOv8 and log experiments to MLflow.

### 2. Run Inference API

```bash
docker run -p 8000:8000 yolo-infer
```

* Endpoint: `POST /predict`
* Example with `curl`:

```bash
curl -X POST "http://localhost:8000/predict" \
    -F "file=@datasets/coco128/images/train/000000000009.jpg"
```

---

## **Experiment Tracking**

* All training runs and metrics are logged to **MLflow**.
* Default artifact path in Docker Compose: `mlflow/mlartifacts/yolo-experiments`
* Access MLflow UI: `http://localhost:5001`

---

## **Testing**

### Unit tests

```bash
pytest tests/unit
```

### Smoke tests

```bash
pytest -m smoke
```

> Unit tests cover model training/inference functions.
> Smoke tests verify the end-to-end pipeline (training → logging → inference).

---

## **Prefect Workflow**

* The Prefect flow orchestrates:

  1. Data prepartion & Model training 
  2. Inference Server preparation
  3.  Trigger inference endpoint



---

## **Reproducibility**

* All dependencies are pinned in `requirements.txt`.
* Docker containers encapsulate the environment for training and inference.

```bash
docker-compose up mlflow
docker-compose run train
docker-compose run infer

```

* Training results are stored in `mlflow/mlartifacts` for reproducibility.

---

## **Optional Improvements**

* Add CI/CD (GitHub Actions) to run tests, build Docker images, and trigger Prefect flows automatically.
* Integrate model monitoring with Evidently or Prometheus.
* Extend dataset to COCO 2017 for full-scale training.

---

## **References**

* [YOLOv8 Documentation](https://docs.ultralytics.com/)
* [Prefect Docs](https://docs.prefect.io/)
* [MLflow Docs](https://mlflow.org/docs/latest/index.html)
* [FastAPI Docs](https://fastapi.tiangolo.com/)

