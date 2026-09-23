#Se usa una imagen pequeña de python.
FROM python:3.12-slim
#Establece /app como directorio de trabajo del contenedor.
WORKDIR /app
# copiamos las dependencias.
COPY requirements.txt .
#instalamos las dependencias y evita conservar la caché de pip dentro de la imagen.
RUN pip install --no-cache-dir -r requirements.txt
#copiamos el código de la aplicación al contenedor.
COPY app.py .
#Hace que la aplicación no se ejecute como root
USER nobody
#Expone el puerto 3000 para que pueda ser accedido desde fuera del contenedor.
EXPOSE 3000
# El comando CMD indica a Docker cómo ejecutar la aplicación. En este caso, se utiliza Gunicorn para servir la aplicación Flask en el puerto 3000.
CMD ["gunicorn", "--bind", "0.0.0.0:3000", "app:app"]