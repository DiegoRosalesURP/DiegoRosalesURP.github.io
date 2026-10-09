#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

request() {
  curl --silent --show-error \
    --output "$TMP_DIR/response.json" \
    --write-out "%{http_code}" \
    "$@"
}

echo "1/5 - Verificando GET /api/health"
status="$(request "$BASE_URL/api/health")"
test "$status" = "200" || {
  echo "Esperaba HTTP 200 en health; recibí $status"
  cat "$TMP_DIR/response.json"
  exit 1
}
cat "$TMP_DIR/response.json"
echo

echo "2/5 - Verificando POST válido (HTTP 201)"
mensaje="CI-TEST-${GITHUB_RUN_ID:-local}-$$"
status="$(request -X POST "$BASE_URL/api/mensajes" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\":\"Prueba CI\",\"mensaje\":\"$mensaje\"}")"
test "$status" = "201" || {
  echo "Esperaba HTTP 201; recibí $status"
  cat "$TMP_DIR/response.json"
  exit 1
}
cat "$TMP_DIR/response.json"
echo

echo "3/5 - Verificando rechazo sin nombre (HTTP 400)"
status="$(request -X POST "$BASE_URL/api/mensajes" \
  -H "Content-Type: application/json" \
  -d '{"mensaje":"Mensaje sin nombre"}')"
test "$status" = "400" || {
  echo "Esperaba HTTP 400; recibí $status"
  cat "$TMP_DIR/response.json"
  exit 1
}

echo "4/5 - Verificando rechazo de mensaje mayor a 280 caracteres"
payload="$(python -c 'import json; print(json.dumps({"nombre":"Prueba CI","mensaje":"x"*281}))')"
status="$(request -X POST "$BASE_URL/api/mensajes" \
  -H "Content-Type: application/json" \
  -d "$payload")"
test "$status" = "400" || {
  echo "Esperaba HTTP 400; recibí $status"
  cat "$TMP_DIR/response.json"
  exit 1
}

echo "5/5 - Verificando que el mensaje creado aparezca en GET"
status="$(request "$BASE_URL/api/mensajes")"
test "$status" = "200" || {
  echo "Esperaba HTTP 200 al listar mensajes; recibí $status"
  cat "$TMP_DIR/response.json"
  exit 1
}
python -c '
import json, sys
mensajes = json.load(open(sys.argv[1], encoding="utf-8"))
esperado = sys.argv[2]
assert any(m.get("mensaje") == esperado for m in mensajes), \
    "El mensaje creado no aparece en GET /api/mensajes"
print("Mensaje encontrado correctamente en la lista.")
' "$TMP_DIR/response.json" "$mensaje"

echo "Todas las pruebas de integración finalizaron correctamente."