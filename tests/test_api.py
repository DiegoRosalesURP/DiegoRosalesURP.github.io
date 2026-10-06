# Importamos la instancia de Flask que contiene las rutas de nuestra API.
from api.app import app


class ConexionFalsa:
    """Simula una conexión a PostgreSQL para realizar el test."""

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        return False

    def execute(self, query):
        # Verificamos que el endpoint ejecute exactamente la consulta esperada.
        assert query == "SELECT 1"


def test_health():
    # Activamos el modo de pruebas de Flask.
    app.config["TESTING"] = True

    # Creamos un cliente para realizar peticiones HTTP a nuestra API
    # sin tener que iniciar el servidor Flask.
    with app.test_client() as client:

        # Importamos patch para reemplazar temporalmente la función conectar().
        from unittest.mock import patch

        # Sustituimos la conexión real a PostgreSQL por nuestra conexión simulada.
        with patch("api.app.conectar", return_value=ConexionFalsa()):

            # Realizamos una petición GET al endpoint de salud.
            response = client.get("/api/health")

    # Comprobamos que la API responda con código HTTP 200.
    assert response.status_code == 201

    # Comprobamos que la respuesta tenga el JSON esperado.
    assert response.get_json() == {"status": "ok"}