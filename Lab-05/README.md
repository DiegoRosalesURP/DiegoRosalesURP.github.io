# LAB-05: Terraform en Google Cloud

## Evidencia
| Lab | Puntaje | Captura | Carpeta |
|-----|---------|---------|---------|
| GSP233 | 100/100 | evidencia/gsp233.png | 01-gsp233/ |
| GSP497 | 100/100 | evidencia/gsp497.png | 02-gsp497/ |
| GSP345 | 100/100 | evidencia/gsp345.png | 03-gsp345/ |

## Bitácora

### GSP233
**Qué hice:** Seguí los pasos del laboratorio al pie de la letra. Cloné el repositorio, revisé la configuración de Terraform (que involucraba los providers de `google` y `kubernetes`), inicialicé el entorno y desplegué el clúster con el Service tipo LoadBalancer para NGINX.
**Qué me costó:** El despliegue del clúster de GKE tardó varios minutos. Además, tuve que verificar la política de regiones de mi proyecto porque la región por defecto del laboratorio (`us-central1`) estaba bloqueada, así que tuve que adaptar la configuración para usar `us-east1`.
**Qué cambiaría:** Nada, fue un laboratorio de calentamiento muy directo para entender cómo Terraform maneja dos providers distintos en un mismo grafo de dependencias.

### GSP497
**Qué hice:** Seguí los pasos del laboratorio. Utilicé un script de Makefile (`make create`) para desplegar un clúster de GKE con monitoreo y una política de alertas de Prometheus. Luego revisé las métricas en Cloud Monitoring y finalmente destruí todo con `make teardown`.
**Qué me costó:** En este caso no hubo nada difícil solo fue seguir la guía.
**Qué cambiaría:** Nada, fue un laboratorio de calentamiento muy directo para entender el ciclo de vida de la infraestructura (`create` y `destroy`).

### GSP345
**Qué hice:** Al ser un Challenge Lab, tuve que construir toda la infraestructura desde cero sin instrucciones paso a paso. Escribí los módulos de `instances` y `storage`, configuré el backend remoto en GCS, importé las VMs preexistentes, modifiqué sus tipos de máquina, destruí una instancia, usé el módulo del Registry de Google para crear una VPC con subredes, y finalmente configuré una regla de firewall.
**Qué me costó:** Fue el laboratorio más desafiante. Tuve un problema principal:
1. El validador automático de Google Skills cambió los nombres exactos de los recursos que debía crear respecto a lo que decía la guía base. Por ejemplo, el nombre del bucket de Cloud Storage, el nombre de la tercera instancia a crear (que debía ser `tf-instance-235049` o similar) y el nombre de la VPC, no coincidían con los textos iniciales. Al no usar los nombres exactos indicados por el sistema de Google en ese momento, el validador no reconocía mis recursos y no me daba los puntos, obligándome a modificar el código y aplicar los cambios varias veces.
**Qué cambiaría:** Revisaría siempre el mensaje exacto de error del validador de Google Skills antes de escribir el código de Terraform, ya que es la única fuente de verdad para los nombres dinámicos de los recursos. Además, revisaría el estado real de los recursos (`gcloud compute instances list`) antes de escribir, para evitar conflictos con las VMs ya creadas.

## Uso de IA
**Qué le pedí:** Le pedí ayuda para estructurar los módulos de Terraform, interpretar los mensajes de error del `plan` (como los errores 412 de restricción de ubicación y los errores de imágenes deprecadas), y para redactar la estructura de esta bitácora.
**Qué me dio:** Me proporcionó los bloques de código HCL para los módulos de instancias y storage, comandos exactos para importar recursos, y explicaciones sobre cómo funcionaba el bloqueo de estado (state locking) en el backend de GCS.
**Qué corregí:** El agente asumió inicialmente que las instancias estaban en `us-east1-d` y tenían tipo `e2-medium` (como decía una versión vieja de la guía). Tuve que corregir el código manualmente para que coincidiera con la zona real (`us-east1-c` primero, y luego `us-west1`) y el tipo real (`e2-micro`). También tuve que cambiar la imagen del disco de `debian-11` a `debian-12` para evitar que la importación fallara.