FROM nginxinc/nginx-unprivileged:1-alpine3.24

LABEL org.opencontainers.image.source="https://github.com/DiegoRosalesURP/DiegoRosalesURP.github.io"

# Actualizar paquetes del sistema para corregir vulnerabilidades
USER root
RUN apk upgrade --no-cache

# Restaurar usuario sin privilegios
USER 101

COPY index.html /usr/share/nginx/html/index.html
COPY estilos.css /usr/share/nginx/html/estilos.css
COPY libro-de-visitas.js /usr/share/nginx/html/libro-de-visitas.js
COPY web/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
