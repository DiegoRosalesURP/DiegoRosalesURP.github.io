FROM nginx:1.27-alpine

COPY index.html /usr/share/nginx/html/index.html
COPY estilos.css /usr/share/nginx/html/estilos.css
COPY libro-de-visitas.js /usr/share/nginx/html/libro-de-visitas.js
COPY web/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80