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
  vcn_id         = oci_core_vcn.tdc10.id
  display_name   = var.internet_gateway.display_name
}

resource "oci_core_default_route_table" "public" {
  compartment_id             = oci_identity_compartment.tdc10.id
  manage_default_resource_id = oci_core_vcn.tdc10.default_route_table_id
  display_name               = var.public_subnet.route_table_name

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.public.id
    description       = "Salida a Internet para la subred publica"
  }
}

resource "oci_core_instance" "public" {
  compartment_id      = oci_identity_compartment.tdc10.id
  availability_domain = data.oci_identity_availability_domains.available.availability_domains[0].name
  display_name        = var.instance.display_name
  shape               = var.instance.shape

  shape_config {
    ocpus         = 1
    memory_in_gbs = 2
  }

  source_details {
    source_id   = data.oci_core_images.oracle_linux.images[0].id
    source_type = "image"
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
    display_name     = "${var.instance.display_name}-vnic"
  }

  metadata = var.ssh_authorized_key == "" ? {} : {
    ssh_authorized_keys = trimspace(var.ssh_authorized_key)
  }
}
