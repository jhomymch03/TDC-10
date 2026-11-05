terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0, < 8.0.0"
    }
  }

  # GitHub Actions recibe la direccion del estado remoto mediante
  # TF_HTTP_ADDRESS. No se guarda la URL preautenticada en el repositorio.
  backend "http" {}
}
