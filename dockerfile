# Usa una imagen base de Python
FROM python:3.9

# Instala dependencias necesarias
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libtesseract-dev \
    poppler-utils

# Crea un directorio de trabajo
WORKDIR /app

# Copia los archivos del proyecto al contenedor
COPY . .

# Instala las dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Exponer el puerto en el que correrá la API
EXPOSE 8000

# Comando para ejecutar la API en Render
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
