#!/bin/bash
set -e

if [ ! -f .env ]; then
  cp .env.example .env
  PASSWORD=$(openssl rand -hex 16)
  sed -i "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$PASSWORD/" .env
  echo "Archivo .env de desarrollo generado."
else
  echo "Archivo .env ya existe; se conserva."
fi
