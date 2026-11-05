variable "compartment_id" {
  description = "OCID del compartimento padre (en el video se usa el OCID de la tenancy)."
  type        = string

  validation {
    condition     = startswith(var.compartment_id, "ocid1.")
    error_message = "compartment_id debe ser un OCID valido de OCI."
  }
}

variable "compartment_name" {
  description = "Nombre del compartimento que creara Terraform."
  type        = string
  default     = "tdc10-terraform-github-actions"
}

variable "compartment_description" {
  description = "Descripcion del compartimento de la practica."
  type        = string
  default     = "Infraestructura OCI administrada con Terraform y GitHub Actions"
}

variable "vcn" {
  description = "Configuracion de la red virtual de OCI."
  type = object({
    cidr_blocks  = list(string)
    display_name = string
  })
  default = {
    cidr_blocks  = ["10.23.0.0/20"]
    display_name = "tdc10-vcn"
  }
}

variable "public_subnet" {
  description = "Configuracion de la subred publica."
  type = object({
    cidr_block       = string
    display_name     = string
    route_table_name = string
  })
  default = {
    cidr_block       = "10.23.11.0/24"
    display_name     = "tdc10-public-subnet"
    route_table_name = "tdc10-public-routes"
  }
}

variable "internet_gateway" {
  description = "Configuracion del gateway de Internet."
  type = object({
    display_name = string
  })
  default = {
    display_name = "tdc10-internet-gateway"
  }
}

variable "instance" {
  description = "Configuracion de la instancia de computo."
  type = object({
    display_name = string
    shape        = string
  })
  default = {
    display_name = "tdc10-public-vm"
    shape        = "VM.Standard.E2.1.Micro"
  }
}

variable "image" {
  description = "Filtro para seleccionar automaticamente la imagen mas reciente compatible."
  type = object({
    operating_system         = string
    operating_system_version = string
  })
  default = {
    operating_system         = "Oracle Linux"
    operating_system_version = "8"
  }
}

variable "ssh_authorized_key" {
  description = "Clave publica SSH opcional para acceder a la instancia."
  type        = string
  default     = ""
}
