# Postgres con el esquema del libro de visitas ya incluido.
#
# La imagen oficial ejecuta, en orden alfabético, todo .sql que encuentre en
# /docker-entrypoint-initdb.d/, pero SOLO si el directorio de datos está vacío,
# es decir, la primera vez que arranca con un volumen nuevo.
FROM postgres:16-alpine

# gosu no es necesario porque el contenedor se ejecuta como postgres.
RUN rm -f /usr/local/bin/gosu

COPY init/ /docker-entrypoint-initdb.d/

USER postgres
