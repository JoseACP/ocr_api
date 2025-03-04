# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.12

# Usa una imagen base ligera de Python
FROM python:${PYTHON_VERSION}-slim as base

# Evita archivos pyc y problemas de buffering
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Configura el directorio de trabajo
WORKDIR /app

# Instala dependencias del sistema necesarias para OpenCV y Tesseract
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libtesseract-dev \
    poppler-utils \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*  # Limpia archivos innecesarios para reducir tamaño

# Agrega un usuario no root para seguridad
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Copia el archivo de dependencias y las instala
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Cambia al usuario no root
USER appuser

# Copia el código fuente dentro del contenedor
COPY . .

# Expone el puerto en el que correrá la API
EXPOSE 4000

# Comando para ejecutar la API
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "4000"]
