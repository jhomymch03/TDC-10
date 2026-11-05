# TDC-10: Oracle Cloud con Terraform y GitHub Actions

Esta practica reproduce el flujo del video **Oracle Cloud Infrastructure as Code Using Terraform and GitHub Actions**. La infraestructura se define con Terraform, se versiona en GitHub y se ejecuta manualmente desde GitHub Actions.

## Arquitectura

El proyecto crea seis recursos principales en OCI:

1. Un compartimento para aislar la practica.
2. Una Virtual Cloud Network (VCN).
3. Una subred publica.
4. Un Internet Gateway.
5. Una tabla de rutas con salida a Internet.
6. Una instancia de computo `VM.Standard.E2.1.Micro` con Oracle Linux 8.

Terraform selecciona automaticamente el primer dominio de disponibilidad y la imagen compatible mas reciente. El estado se guarda en OCI Object Storage mediante el backend HTTP, sin publicar la URL preautenticada en el repositorio.

## Estructura

```text
.
|-- .github/workflows/OCI.yml
|-- Terraform/
|   |-- main.tf
|   |-- outputs.tf
|   |-- provider.tf
|   |-- terraform.tf
|   |-- terraform.tfvars.example
|   `-- variables.tf
|-- HelpScript.ps1
`-- README.md
```

## 1. Preparar Oracle Cloud

1. Inicia sesion en OCI y copia el OCID de la tenancy, el OCID del usuario y la region.
2. En **Perfil > API keys**, agrega una clave publica PEM. Conserva de forma privada la clave PEM correspondiente y copia su fingerprint.
3. En **Object Storage**, crea un bucket para el estado de Terraform.
4. Crea una solicitud preautenticada para el objeto `terraform.tfstate` con permisos de lectura y escritura. Guarda la URL completa: OCI solo la muestra una vez.
5. Verifica que el usuario tenga permisos para administrar compartimentos, redes e instancias de computo.

La URL preautenticada y la clave privada permiten acceso a recursos de tu cuenta. No deben escribirse en archivos versionados ni compartirse en capturas.

## 2. Crear el repositorio y los secretos de GitHub

Sube este proyecto a un repositorio propio. Luego abre **Settings > Secrets and variables > Actions** y crea estos secretos:

| Secreto | Contenido |
|---|---|
| `OCI_USER_OCID` | OCID del usuario de OCI |
| `OCI_FINGERPRINT` | Fingerprint de la API key |
| `OCI_REGION` | Region, por ejemplo `us-ashburn-1` |
| `OCI_TENANCY_OCID` | OCID de la tenancy/compartimento padre |
| `OCI_KEY_FILE` | Contenido completo de la clave privada PEM |
| `OCI_STATE_ADDRESS` | URL preautenticada del objeto `terraform.tfstate` |
| `OCI_SSH_PUBLIC_KEY` | Clave publica SSH; puede dejarse vacia si no se usara SSH |

## 3. Validar localmente

Terraform ya esta instalado en este equipo. Para validar la sintaxis sin conectarte a OCI:

```powershell
Set-Location .\Terraform
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

Para ejecutar un plan local, copia `terraform.tfvars.example` como `terraform.tfvars`, reemplaza los valores y configura primero `~/.oci/config`.

## 4. Ejecutar la canalizacion

1. Abre la pestaña **Actions** del repositorio.
2. Selecciona **OCI con Terraform** y pulsa **Run workflow**.
3. Ejecuta primero `plan` y revisa los seis recursos propuestos.
4. Ejecuta `apply` para desplegar la solucion.
5. En OCI, comprueba el compartimento, la VCN, la subred, el gateway, la tabla de rutas y la instancia.
6. Cuando termines la practica, ejecuta `destroy` para evitar consumo o cargos.

## Resultado esperado

El trabajo queda correcto cuando el workflow termina en verde y muestra los outputs `compartment_id`, `vcn_id`, `public_subnet_id`, `instance_id` e `instance_public_ip`. En la consola de OCI, la instancia debe aparecer en estado **Running** dentro del compartimento `tdc10-terraform-github-actions`.

## Ruta de autoaprendizaje

El archivo [AUTOAPRENDIZAJE.md](AUTOAPRENDIZAJE.md) contiene una ruta guiada para comprender la practica, no solamente ejecutarla. Incluye conceptos previos, ejercicios progresivos, preguntas de comprobacion, retos, evidencias sugeridas y una rubrica de autoevaluacion.

## Diferencias necesarias respecto al repositorio del video

El repositorio original tenia los recursos comentados y contenia valores de la cuenta del autor. Esta version activa los recursos, elimina esos datos, usa imagen y dominio de disponibilidad dinamicos, protege el estado remoto mediante un secreto y actualiza las acciones oficiales de GitHub.
