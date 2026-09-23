#!/usr/bin/env bash

set -euo pipefail

echo "Esperando a que Docker esté disponible..."

for _ in $(seq 1 60); do
  if docker info >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! docker info >/dev/null 2>&1; then
  echo "Docker no está disponible."
  exit 1
fi

echo "Docker está disponible."
echo "Iniciando servicios..."

docker compose up -d

echo "Servicios iniciados."
docker compose ps