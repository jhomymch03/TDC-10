output "compartment_id" {
  description = "OCID del compartimento creado para la practica."
  value       = oci_identity_compartment.tdc10.id
}

output "vcn_id" {
  description = "OCID de la red virtual creada."
  value       = oci_core_vcn.tdc10.id
}

output "public_subnet_id" {
  description = "OCID de la subred publica."
  value       = oci_core_subnet.public.id
}

output "instance_id" {
  description = "OCID de la instancia de computo."
  value       = oci_core_instance.public.id
}

output "instance_public_ip" {
  description = "Direccion IP publica asignada a la instancia."
  value       = oci_core_instance.public.public_ip
}
