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
