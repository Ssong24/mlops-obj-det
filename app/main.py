from fastapi import FastAPI, UploadFile, File
from pydantic import BaseModel
from ultralytics import YOLO
import uvicorn
import io
from PIL import Image

# Create FastAPI application instance
# main app object - handle all HTTP requests
app = FastAPI()

# Load the trained YOLO model
# Make sure the model file exists at this path
model = YOLO("weights/best.pt")  

# Define the response data structure using Pydantic
# This ensures type safety and automatic API documentation
class Prediction(BaseModel):
    boxes: list[list[float]]  # Bounding box coordinates [x1,y1,x2,y2] for each detection
    scores: list[float]       # Confidence scores (0-1) for each detection
    labels: list[str]         # Class names for each detection

# Health check endpoint
# GET request to /health - used to verify if the service is running
@app.get("/health")
def health():
    return {"status": "ok"}

# Main prediction endpoint
# POST request to /predict - accepts image file and returns detection results
@app.post("/predict", response_model=Prediction)
async def predict(file: UploadFile = File(...)):
    image = Image.open(io.BytesIO(await file.read()))
    results = model(image)

    boxes, scores, labels = [], [], []
    for r in results[0].boxes:
        boxes.append(r.xyxy[0].tolist())  # [x1,y1,x2,y2]
        scores.append(float(r.conf[0]))
        labels.append(model.names[int(r.cls[0])])

    return Prediction(boxes=boxes, scores=scores, labels=labels)


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
