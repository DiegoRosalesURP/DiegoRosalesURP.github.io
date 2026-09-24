# Perfil — Diego Rosales

Sitio personal publicado en https://DiegoRosalesURP.github.io

## Cómo se publica
Cada push a `main` despliega automáticamente con GitHub Pages.

## Flujo de trabajo
- `main` protegida; todo cambio entra por pull request
- Una rama por cambio: `feature/*`, `fix/*`
- Mensajes de commit en imperativo, ≤ 50 caracteres

## Historial del curso
- **S02** — Sitio inicial, ramas y pull requests
- **S03** — Libro de visitas en tres contenedores, Compose, Codespaces y los seis retos

## Bitácora de decisiones

### Reto 1: Reducir la imagen de la API con multi-stage build

* **Decisión:** Se utilizó un Dockerfile multi-stage para separar la etapa de construcción de dependencias de la imagen final de ejecución. La imagen final conserva únicamente lo necesario para ejecutar la API.

* **Alternativas que evalué:**

  * **Mantener un Dockerfile de una sola etapa:** era más sencillo, pero dejaba herramientas y elementos de construcción en la imagen final.
  * **Usar una imagen runtime independiente y copiar únicamente los artefactos necesarios:** reduce el contenido final, pero requiere separar correctamente las dependencias de ejecución de las de construcción.

* **Por qué elegí esta:** El multi-stage permite separar construcción y ejecución y reducir el tamaño de la imagen final. Docker recomienda este enfoque para evitar que dependencias innecesarias terminen en la imagen de producción.

* **Fuentes consultadas:** [Docker — Multi-stage builds](https://docs.docker.com/get-started/docker-concepts/building-images/multi-stage-builds/) y [Docker — Building best practices](https://docs.docker.com/build/building/best-practices/).

* **Cómo lo verifiqué:** Comparé el tamaño de la imagen antes y después mediante `docker images` y revisé las capas finales con `docker history`. La imagen final quedó por debajo de la mitad del tamaño de la imagen inicial.

```text
PS C:\Users\diego\perfil> docker images perfil-api

IMAGE                    ID             DISK USAGE   CONTENT SIZE
perfil-api:1.0           70efd857129b   219MB        53.7MB
perfil-api:reto1-final3  514d7577900a    98.7MB        24.9MB
```

También se revisaron las capas de la imagen final:

```text
PS C:\Users\diego\perfil> docker history perfil-api:reto1-final3

IMAGE          CREATED          CREATED BY                                      SIZE
514d7577900a   17 minutes ago   CMD ["gunicorn" "--bind" "0.0.0.0:3000" "app…   0B
<missing>      17 minutes ago   EXPOSE [3000/tcp]                               0B
<missing>      17 minutes ago   USER nobody                                     0B
<missing>      17 minutes ago   ENV PYTHONDONTWRITEBYTECODE=1                   0B
<missing>      17 minutes ago   ENV PATH=/venv/bin:/usr/local/sbin:/usr/loca…   0B
<missing>      17 minutes ago   COPY app.py . # buildkit                        12.3kB
<missing>      17 minutes ago   COPY /venv /venv # buildkit                     20.5MB
<missing>      23 minutes ago   WORKDIR /app                                    8.19kB
<missing>      23 minutes ago   RUN /bin/sh -c apk add --no-cache python3 # …   44.4MB
<missing>      6 days ago       CMD ["/bin/sh"]                                 0B
<missing>      6 days ago       ADD alpine-minirootfs-3.22.6-x86_64.tar.gz /…   8.97MB
```

* **Qué no me funcionó:** La primera versión de la imagen incluía elementos innecesarios de construcción. Aprendí que no basta con instalar menos paquetes: también es necesario evitar que las dependencias y herramientas utilizadas durante la construcción lleguen a la etapa final.

---

### Reto 2: Healthchecks y arranque ordenado

* **Decisión:** Se agregaron `healthcheck` a `web`, `api` y `db`, y se configuró `depends_on` con condiciones `service_healthy` para respetar el orden de arranque.

* **Alternativas que evalué:**

  * **Usar solamente `depends_on`:** es sencillo, pero no garantiza que el servicio dependiente esté realmente listo para recibir solicitudes.
  * **Usar scripts externos de espera:** permite controlar con mayor detalle la espera, pero agrega complejidad y lógica adicional al proyecto.

* **Por qué elegí esta:** Los healthchecks permiten que Docker Compose conozca el estado real de cada servicio y permiten iniciar los servicios dependientes cuando sus dependencias están saludables.

* **Fuentes consultadas:** [Docker Compose — Control startup and shutdown order](https://docs.docker.com/compose/how-tos/startup-order/).

* **Cómo lo verifiqué:** Ejecuté `docker compose up -d --wait` y posteriormente `docker compose ps`. Los servicios `web`, `api` y `db` aparecieron con estado `healthy`.

```text
PS C:\Users\diego\perfil> docker compose up -d --wait

[+] up 5/5
 ✔ Network perfil_red_frontend Created                            0.1s
 ✔ Network perfil_red_backend  Created                            0.0s
 ✔ Container perfil-db-1       Healthy                           12.8s
 ✔ Container perfil-api-1      Healthy                           12.7s
 ✔ Container perfil-web-1      Healthy                           17.5s
```

Luego:

```text
PS C:\Users\diego\perfil> docker compose ps

NAME           IMAGE        COMMAND                  SERVICE   CREATED          STATUS                    PORTS
perfil-api-1   perfil-api   "gunicorn --bind 0.0…"   api       21 seconds ago   Up 15 seconds (healthy)   3000/tcp
perfil-db-1    perfil-db    "docker-entrypoint.s…"   db        22 seconds ago   Up 21 seconds (healthy)   5432/tcp
perfil-web-1   perfil-web   "/docker-entrypoint.…"   web       21 seconds ago   Up 9 seconds (healthy)    0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp
```

* **Qué no me funcionó:** Inicialmente se consideró solamente iniciar los servicios con `docker compose up -d`, pero esto no era suficiente para demostrar que las dependencias estuvieran listas. Se incorporaron healthchecks para poder verificar el estado real.

---

### Reto 3: Ejecutar los servicios sin privilegios

* **Decisión:** Se configuraron los Dockerfiles para ejecutar los procesos con usuarios no root. PostgreSQL mantiene su usuario `postgres` y los servicios de aplicación utilizan usuarios sin privilegios.

* **Alternativas que evalué:**

  * **Ejecutar todos los servicios como root:** es más sencillo y puede evitar problemas de permisos, pero aumenta los privilegios disponibles dentro del contenedor.
  * **Crear usuarios específicos en cada imagen:** requiere configurar permisos correctamente, pero reduce los privilegios del proceso.

* **Por qué elegí esta:** El objetivo del reto es reducir privilegios y seguir las buenas prácticas de seguridad de contenedores.

* **Fuentes consultadas:** [Docker — Building best practices](https://docs.docker.com/build/building/best-practices/).

* **Cómo lo verifiqué:** Ejecuté `docker compose exec web whoami`, `docker compose exec api whoami` y `docker compose exec db whoami`. Los servicios se ejecutaron con usuarios no root.

```text
PS C:\Users\diego\perfil> docker compose exec web whoami
nginx

PS C:\Users\diego\perfil> docker compose exec api whoami
nobody

PS C:\Users\diego\perfil> docker compose exec db whoami
postgres
```

* **Qué no me funcionó:** Al modificar usuarios fue necesario revisar permisos de archivos y directorios utilizados por los procesos. Aprendí que cambiar el usuario de ejecución también requiere comprobar que dicho usuario pueda acceder a los recursos necesarios.

---

### Reto 4: Segmentar la red entre los servicios

* **Decisión:** Se crearon dos redes de Docker: `red_frontend` y `red_backend`. `web` solamente pertenece a `red_frontend`, `db` solamente a `red_backend` y `api` pertenece a ambas.

* **Alternativas que evalué:**

  * **Una sola red para los tres servicios:** es más sencilla de configurar, pero permite que cualquier servicio pueda resolver y comunicarse directamente con los demás.
  * **Dos redes con la API como punto intermedio:** requiere más configuración, pero limita la comunicación entre servicios.

* **Por qué elegí esta:** La API debe comunicarse con la base de datos, mientras que `web` no necesita acceso directo a `db`. La segmentación reduce la superficie de comunicación entre contenedores.

* **Fuentes consultadas:** [Docker — Networking](https://docs.docker.com/engine/network/) y [Docker Compose — Networking](https://docs.docker.com/compose/how-tos/networking/).

* **Cómo lo verifiqué:** `docker compose exec web getent hosts db` no obtuvo resolución, mientras que `docker compose exec api getent hosts db` resolvió `db` correctamente. También se verificó que solamente `web` publicara el puerto `8080` hacia el host.

```text
PS C:\Users\diego\perfil> docker compose exec web getent hosts db

PS C:\Users\diego\perfil>
```

Desde `api`:

```text
PS C:\Users\diego\perfil> docker compose exec api getent hosts db

172.19.0.2        db  db
```

* **Qué no me funcionó:** Durante la configuración fue necesario revisar cuidadosamente a qué redes pertenecía cada servicio. Aprendí que no basta con crear varias redes; también hay que asignar cada servicio únicamente a las redes que necesita.

---

### Reto 5: Reducir vulnerabilidades de la imagen API (No terminado)

* **Decisión:** Se realizó un análisis de vulnerabilidades de la imagen API utilizando Trivy y no se presentaron vulnerabilidades `HIGH` ni `CRITICAL`, así que se buscó eliminar vulnerabilidades `MEDIUM` y `LOW`. El reto se intentó, pero no se cerró porque el análisis posterior presentó resultados inconsistentes con el contenido real instalado en la imagen, ya que presentaba errores `HIGH` en paquetes que no estaban instalados.

* **Alternativas que evalué:**

  * **Actualizar las dependencias Python detectadas:** podía reducir vulnerabilidades conocidas, pero debía comprobar que las versiones actualizadas fueran realmente necesarias y compatibles.
  * **Cambiar la imagen base:** podía reducir vulnerabilidades del sistema operativo, pero también podía introducir incompatibilidades y no solucionaba necesariamente los hallazgos de Python.

* **Por qué elegí esta:** Primero se intentó actualizar dependencias identificadas por el escaneo y después comprobar nuevamente el resultado. Al detectar inconsistencias, se decidió no presentar el reto como completado sin una evidencia confiable.

* **Fuentes consultadas:** [Trivy — Documentation](https://trivy.dev/latest/) y documentación de Docker sobre buenas prácticas de construcción de imágenes.

* **Cómo lo verifiqué:** Se realizó un escaneo inicial con Trivy y posteriormente nuevos escaneos después de modificar dependencias.

#### Escaneo inicial

```text
PS C:\Users\diego\perfil> trivy image --severity LOW,MEDIUM,HIGH,CRITICAL perfil-api:reto1-final3

2026-09-24T13:53:42-05:00 INFO [vuln] Vulnerability scanning is enabled
2026-09-24T13:53:42-05:00 INFO [secret] Secret scanning is enabled
2026-09-24T13:53:42-05:00 INFO Detected OS family="alpine" version="3.22.6"
2026-09-24T13:53:42-05:00 INFO [alpine] Detecting vulnerabilities...
2026-09-24T13:53:42-05:00 INFO [python-pkg] Detecting vulnerabilities...

Report Summary

Target: perfil-api:reto1-final3 (alpine 3.22.6)

Alpine:
Vulnerabilities: 0

Python:
Total: 7
LOW: 2
MEDIUM: 5
HIGH: 0
CRITICAL: 0
```

#### Actualización de pip

Se reconstruyó la imagen:

```text
PS C:\Users\diego\perfil> docker build --no-cache -t perfil-api:reto5-final -f api/Dockerfile api

[+] Building 29.0s (14/14) FINISHED
...
=> naming to docker.io/library/perfil-api:reto5-final
```

Se verificó la versión de `pip`:

```text
PS C:\Users\diego\perfil> docker run --rm perfil-api:reto5-final /venv/bin/pip --version

pip 26.2.1 from /venv/lib/python3.12/site-packages/pip (python 3.12)
```

#### Segundo escaneo

```text
PS C:\Users\diego\perfil> trivy image --severity LOW,MEDIUM,HIGH,CRITICAL perfil-api:reto5-final

2026-09-24T14:20:57-05:00 INFO [vuln] Vulnerability scanning is enabled
2026-09-24T14:20:57-05:00 INFO [secret] Secret scanning is enabled
2026-09-24T14:20:58-05:00 WARN Third-party SBOM may lead to inaccurate vulnerability detection
2026-09-24T14:20:58-05:00 WARN Recommend using Trivy to generate SBOMs

Report Summary

Target: perfil-api:reto5-final (alpine 3.22.6)

Alpine:
Vulnerabilities: 0

Python:
Total: 4
LOW: 1
MEDIUM: 1
HIGH: 2
CRITICAL: 0
```

* **Qué no me funcionó:** La segunda ejecución de Trivy mostró resultados que no coincidían con `pip show`, `pip freeze` ni con la inspección de los módulos instalados. Por esta inconsistencia no se consideró demostrado el requisito de reducir al menos una vulnerabilidad `HIGH` o `CRITICAL`. El reto queda registrado como **intentado, pero no completado**.

---

### Reto 6: Gestión segura de secretos

* **Decisión:** Se evitó almacenar las credenciales reales en el repositorio. Se agregó `.env` al `.gitignore`, se creó `.env.example` sin contraseña y se configuró el Codespace para generar automáticamente un `.env` de desarrollo con una contraseña aleatoria.

* **Alternativas que evalué:**

  * **Guardar las credenciales directamente en `compose.yaml`:** es sencillo, pero expone las credenciales en el repositorio y en la configuración del proyecto.
  * **Usar un archivo `.env` ignorado por Git:** permite separar las variables sensibles del código y mantener un `.env.example` como plantilla.

* **Por qué elegí esta:** Permite que cada entorno genere sus propias credenciales sin incluir secretos reales en Git. Además, el proyecto puede iniciar automáticamente en un Codespace nuevo.

* **Fuentes consultadas:** [Docker Compose — Environment variables](https://docs.docker.com/compose/how-tos/environment-variables/) y [GitHub Codespaces — Dev containers](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers).

* **Cómo lo verifiqué:** `git check-ignore -v .env` confirmó que `.env` está ignorado. `git grep -n "app123"` no encontró la contraseña en el repositorio y `git log --all --full-history -- .env` no encontró el archivo en el historial. También se revisaron las capas de las imágenes con `docker history --no-trunc`.

```text
PS C:\Users\diego\perfil> git check-ignore -v .env

.gitignore:3:.env       .env

PS C:\Users\diego\perfil> git grep -n "app123"

PS C:\Users\diego\perfil>
```

Se revisaron las capas de la imagen API:

```text
PS C:\Users\diego\perfil> docker history --no-trunc perfil-api

IMAGE          CREATED          CREATED BY
sha256:02296f31e6eb57c04a1bfba4f461a082685bd7944892bf96cb7cfcace25ad67a
26 hours ago   CMD ["gunicorn" "--bind" "0.0.0.0:3000" "app:app"]

<missing>      26 hours ago   EXPOSE [3000/tcp]
<missing>      26 hours ago   USER nobody
<missing>      26 hours ago   ENV PYTHONDONTWRITEBYTECODE=1
<missing>      26 hours ago   ENV PATH=/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
<missing>      26 hours ago   COPY app.py . # buildkit
<missing>      26 hours ago   COPY /venv /venv # buildkit
<missing>      26 hours ago   WORKDIR /app
<missing>      26 hours ago   RUN /bin/sh -c apk add --no-cache python3
<missing>      7 days ago     CMD ["/bin/sh"]
<missing>      7 days ago     ADD alpine-minirootfs-3.22.6-x86_64.tar.gz / # buildkit
```

También se revisó la imagen de PostgreSQL:

```text
PS C:\Users\diego\perfil> docker history --no-trunc perfil-db

IMAGE          CREATED          CREATED BY
sha256:bb096d35fd640c4c3a19249b857fdf64745e1f16a3794e4ce44201d90d4414d3
30 hours ago   USER postgres

<missing>      30 hours ago   COPY init/ /docker-entrypoint-initdb.d/
<missing>      7 days ago     CMD ["postgres"]
<missing>      7 days ago     EXPOSE map[5432/tcp:{}]
<missing>      7 days ago     ENTRYPOINT ["docker-entrypoint.sh"]
...
```

* **Qué no me funcionó:** En el primer intento, `.env.example` contenía accidentalmente caracteres de un comando de PowerShell (`@"` y `"@ | Set-Content`). Esto impedía que un Codespace nuevo generara correctamente `.env`. Se corrigió mediante una rama independiente y un Pull Request. Después de la corrección, un Codespace nuevo inició los servicios correctamente y el guestbook funcionó.
