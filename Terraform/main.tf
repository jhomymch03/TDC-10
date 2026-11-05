data "oci_identity_availability_domains" "available" {
  compartment_id = var.compartment_id
}


data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_id
  operating_system         = var.image.operating_system
  operating_system_version = var.image.operating_system_version
  shape                    = var.instance.shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}


resource "oci_identity_compartment" "tdc10" {
  compartment_id = var.compartment_id
  description    = var.compartment_description
  name           = var.compartment_name
}


resource "oci_core_vcn" "tdc10" {
  compartment_id = oci_identity_compartment.tdc10.id
  cidr_blocks    = var.vcn.cidr_blocks
  display_name   = var.vcn.display_name
}


resource "oci_core_subnet" "public" {
  compartment_id             = oci_identity_compartment.tdc10.id
  vcn_id                     = oci_core_vcn.tdc10.id
  cidr_block                 = var.public_subnet.cidr_block
  display_name               = var.public_subnet.display_name
  prohibit_public_ip_on_vnic = false
  prohibit_internet_ingress  = false
}


resource "oci_core_internet_gateway" "public" {
  compartment_id = oci_identity_compartment.tdc10.id
