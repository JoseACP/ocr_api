from fastapi import FastAPI, File, UploadFile
import cv2
import pytesseract
import os
from pdf2image import convert_from_bytes
from io import BytesIO
import numpy as np

app = FastAPI()

# Configurar Tesseract OCR (Render ya lo instalará con `build.sh`)
pytesseract.pytesseract.tesseract_cmd = "/usr/bin/tesseract"  # En Linux

def pdf_to_images(pdf_bytes):
    """Convierte un PDF (bytes) a imágenes en memoria."""
    pages = convert_from_bytes(pdf_bytes.read(), fmt="png")
    return [np.array(page) for page in pages]

def extract_text_from_images(image_arrays):
    """Extrae texto de imágenes en memoria usando Tesseract OCR."""
    extracted_text = ""
    for img_array in image_arrays:
        img = cv2.cvtColor(img_array, cv2.COLOR_RGB2BGR)
        extracted_text += pytesseract.image_to_string(img) + "\n"
    return extracted_text

@app.post("/extract-text/")
async def extract_text_from_pdf(file: UploadFile = File(...)):
    """Procesa el PDF sin guardarlo en disco y devuelve el texto extraído."""
    # Convertir PDF a imágenes
    image_arrays = pdf_to_images(file.file)
    
    # Extraer texto
    extracted_text = extract_text_from_images(image_arrays)
    
    return {"filename": file.filename, "extracted_text": extracted_text}
