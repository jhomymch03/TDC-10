# Ruta de autoaprendizaje: OCI, Terraform y GitHub Actions

## Proposito

Esta ruta permite estudiar la practica por etapas y demostrar que se comprende el funcionamiento de la solucion. El objetivo no es memorizar comandos, sino explicar como un cambio escrito en Terraform puede convertirse en infraestructura real mediante una canalizacion automatizada.

## Resultados de aprendizaje

Al finalizar, el estudiante podra:

- Explicar la diferencia entre infraestructura manual e Infraestructura como Codigo (IaC).
- Reconocer la funcion de cada archivo de Terraform.
- Interpretar dependencias entre compartimento, VCN, subred, gateway, rutas e instancia.
- Describir como GitHub Actions autentica Terraform contra OCI sin publicar credenciales.
- Diferenciar `terraform init`, `fmt`, `validate`, `plan`, `apply` y `destroy`.
- Identificar riesgos de seguridad, costos y perdida del estado de Terraform.
- Documentar evidencias tecnicas de una ejecucion.

## Mapa conceptual

```text
Desarrollador
    |
    | push / workflow_dispatch
    v
Repositorio GitHub
    |
    | GitHub Actions + secretos
    v
Terraform -------> Estado remoto en OCI Object Storage
    |
    | Oracle/OCI Provider
    v
Compartimento
    `-- VCN
        |-- Subred publica
        |-- Internet Gateway
        |-- Tabla de rutas
        `-- Instancia de computo
```

## Etapa 1: fundamentos

### Lectura guiada

1. **IaC:** la infraestructura se describe en archivos versionables y repetibles.
2. **Terraform:** compara el estado deseado del codigo con el estado real del proveedor.
3. **Provider OCI:** traduce los recursos HCL en solicitudes a la API de Oracle Cloud.
4. **Estado:** relaciona los bloques de Terraform con los recursos reales y sus OCID.
5. **Pipeline:** ejecuta comprobaciones y despliegues de forma consistente.

### Preguntas de comprobacion

1. ¿Por que es preferible versionar archivos `.tf` en lugar de crear todos los recursos manualmente?
2. ¿Que informacion conserva `terraform.tfstate`?
3. ¿Por que el estado remoto no debe publicarse en GitHub?
4. ¿Cual es la diferencia entre un provider y un recurso?
5. ¿Que ventaja ofrece revisar `plan` antes de ejecutar `apply`?

## Etapa 2: exploracion del codigo

Completa esta tabla despues de leer los archivos del directorio `Terraform`:

| Archivo | Responsabilidad | Pregunta para investigar |
|---|---|---|
| `terraform.tf` | Versiones y backend | ¿Que ocurriria si dos personas modificaran el mismo estado? |
| `provider.tf` | Perfil de autenticacion OCI | ¿De donde obtiene el provider las credenciales? |
| `variables.tf` | Entradas y valores predeterminados | ¿Que variables conviene no dejar fijas? |
| `main.tf` | Datos y recursos de infraestructura | ¿Como infiere Terraform el orden de creacion? |
| `outputs.tf` | Datos mostrados al finalizar | ¿Que outputs sirven como evidencia? |
| `OCI.yml` | Automatizacion en GitHub | ¿Que pasos evitan desplegar codigo invalido? |

### Ejercicio 1: grafo de dependencias

Ubica en `main.tf` las referencias entre recursos. Dibuja flechas desde cada recurso hacia aquello de lo que depende. Comprueba, por ejemplo, que la subred necesita la VCN y el compartimento, mientras que la instancia necesita la subred, una imagen y un dominio de disponibilidad.

### Ejercicio 2: cambio sin despliegue

1. Cambia temporalmente `display_name` de la VCN en `variables.tf`.
2. Ejecuta `terraform fmt -check -recursive`.
3. Cuando exista acceso a OCI, ejecuta solamente `plan`.
4. Predice el resultado antes de leerlo y compara ambas respuestas.
5. Revierte el nombre si no deseas conservarlo.

## Etapa 3: ciclo de trabajo de Terraform

| Comando | Funcion | ¿Modifica OCI? |
|---|---|---|
| `terraform init` | Inicializa backend y providers | No crea la infraestructura |
| `terraform fmt` | Normaliza el formato HCL | No |
| `terraform validate` | Comprueba estructura y tipos | No |
| `terraform plan` | Calcula cambios propuestos | No |
| `terraform apply` | Ejecuta el plan | Si |
| `terraform destroy` | Elimina recursos administrados | Si |

### Practica segura sin OCI

```powershell
Set-Location .\Terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform providers
```

Explica con tus propias palabras la salida de cada comando y anota cualquier advertencia.

## Etapa 4: GitHub Actions y seguridad

Estudia `.github/workflows/OCI.yml` e identifica:

- El disparador manual `workflow_dispatch`.
- Las opciones `plan`, `apply` y `destroy`.
- La instalacion de Terraform.
- La creacion temporal del perfil `~/.oci/config`.
- El uso de secretos sin escribirlos en el repositorio.
- La secuencia `init -> fmt -> validate -> plan -> apply`.

### Analisis de riesgos

Responde:

1. ¿Que podria hacer una persona que obtiene `OCI_KEY_FILE`?
2. ¿Por que `OCI_STATE_ADDRESS` debe almacenarse como secreto?
3. ¿Que archivos excluye `.gitignore` y por que?
4. ¿Que diferencia existe entre una clave publica SSH y una clave privada?
5. ¿Por que `destroy` debe ejecutarse de forma consciente?

Nunca incluyas claves privadas, URLs preautenticadas o archivos de estado en capturas, informes o commits.

## Etapa 5: reto de investigacion

Elige dos actividades:

- Comparar `VM.Standard.E2.1.Micro` con una forma flexible y documentar sus diferencias.
- Investigar como agregar una regla de ingreso SSH limitada a una direccion IP concreta.
- Explicar como se bloquearia el estado para evitar ejecuciones simultaneas.
- Investigar el principio de minimo privilegio en politicas IAM de OCI.
- Agregar etiquetas definidas o libres a todos los recursos.
- Proponer una separacion de ambientes `desarrollo`, `pruebas` y `produccion`.

Para cada actividad registra: fuente consultada, conclusion, cambio propuesto y riesgo asociado.

## Evidencias para la entrega

Cuando se habilite OCI, recopila:

1. Captura del workflow exitoso sin mostrar secretos.
2. Resumen de `terraform plan` con la cantidad de recursos.
3. Compartimento creado en OCI.
4. VCN, subred, gateway y tabla de rutas.
5. Instancia en estado `Running`.
6. Outputs finales de Terraform.
7. Ejecucion de `destroy` al concluir, si el docente no requiere conservar los recursos.

## Autoevaluacion

Califica cada criterio de 0 a 2:

| Criterio | 0 | 1 | 2 |
|---|---|---|---|
| Conceptos IaC | No los explica | Explicacion parcial | Explicacion clara con ejemplo |
| Lectura de HCL | No identifica recursos | Reconoce recursos | Explica relaciones y variables |
| Terraform CLI | Confunde comandos | Distingue algunos | Explica todo el ciclo |
| Automatizacion | No interpreta el workflow | Reconoce pasos | Justifica orden y condiciones |
| Seguridad | Publicaria secretos | Reconoce algunos riesgos | Aplica buenas practicas |
| Evidencias | No documenta | Evidencia incompleta | Evidencia clara y verificable |

Interpretacion:

- **10 a 12:** dominio suficiente para explicar y defender la practica.
- **7 a 9:** comprension funcional; conviene reforzar seguridad o dependencias.
- **0 a 6:** repasar las etapas antes de desplegar recursos reales.

## Preguntas para la defensa oral

1. ¿Que problema resuelve Terraform en esta practica?
2. ¿Como sabe Terraform que debe crear primero la VCN y despues la subred?
3. ¿Por que la instancia puede recibir una IP publica?
4. ¿Que funcion cumple la ruta `0.0.0.0/0`?
5. ¿Que ocurre si se pierde el archivo de estado?
6. ¿Por que el workflow ofrece primero la opcion `plan`?
7. ¿Como se evita publicar la clave privada de OCI?
8. ¿Que verificarias si la instancia no pudiera acceder a Internet?
9. ¿Como se eliminan de forma controlada los recursos creados?
10. ¿Que mejorarias antes de usar esta solucion en produccion?

## Diario de aprendizaje

Al concluir cada sesion registra:

```text
Fecha:
Tema estudiado:
Lo que comprendi:
Duda pendiente:
Error encontrado y solucion:
Siguiente actividad:
```
