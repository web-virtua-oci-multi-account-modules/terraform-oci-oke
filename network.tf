module "create_vcn" {
  count = var.make_new_network ? 1 : 0

  source  = "web-virtua-oci-multi-account-modules/vcn-full/oci"
  version = ">= 1.0.0"

  compartment_id           = var.compartment_id
  cidr_block               = var.cidr_blocks.vcn
  display_name             = "${var.cluster_name}-vcn"
  internet_gateway_name    = "${var.cluster_name}-igtw"
  nat_gateway_name         = "${var.cluster_name}-ngtw"
  service_gateway_name     = "${var.cluster_name}-sgtw"
  public_route_table_name  = "${var.cluster_name}-public-rt"
  private_route_table_name = "${var.cluster_name}-private-rt"
}

### Security List ###
module "create_all_eggres" {
  count = var.make_new_network ? 1 : 0

  source  = "web-virtua-oci-multi-account-modules/security-list/oci"
  version = ">= 1.0.0"

  compartment_id    = var.compartment_id
  vcn_id            = module.create_vcn[0].vcn_id
  name              = "${var.cluster_name}-all-egress"
  allow_cidr_blocks = ["0.0.0.0/0"]
  type              = "egress"

  allow_rules_list = [
    {
      protocol = "all",
      ports    = ["all"]
    }
  ]
}

module "create_sec_list_endpoint" {
  count = var.make_new_network ? 1 : 0

  source  = "web-virtua-oci-multi-account-modules/security-list/oci"
  version = ">= 1.0.0"

  compartment_id = var.compartment_id
  vcn_id         = module.create_vcn[0].vcn_id
  name           = "${var.cluster_name}-endpoint"
  type           = "ingress"

  allow_rules_list = [
    {
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ports       = [80, 443, 6443, 30414]
    },
    {
      protocol    = "tcp"
      cidr_blocks = [var.cidr_blocks.vcn]
      ports       = [80, 443, 12250, 30414]
    },
    {
      protocol    = "icmp"
      cidr_blocks = [var.cidr_blocks.vcn]
      ports       = ["all"]
    }
  ]
}

module "sec_list_service_lb" {
  count = var.make_new_network ? 1 : 0

  source  = "web-virtua-oci-multi-account-modules/security-list/oci"
  version = ">= 1.0.0"

  compartment_id = var.compartment_id
  vcn_id         = module.create_vcn[0].vcn_id
  name           = "${var.cluster_name}-service-lb"
  type           = "ingress"

  allow_rules_list = [
    {
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ports       = [22, 80, 443, 30414]
    }
  ]
}

module "create_sec_list_nodes" {
  count = var.make_new_network ? 1 : 0

  source  = "web-virtua-oci-multi-account-modules/security-list/oci"
  version = ">= 1.0.0"

  compartment_id = var.compartment_id
  vcn_id         = module.create_vcn[0].vcn_id
  name           = "${var.cluster_name}-nodes"
  type           = "ingress"

  allow_rules_list = [
    {
      protocol    = "all"
      cidr_blocks = [var.cidr_blocks.vcn]
      ports       = ["all"]
    },
    {
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ports       = [22, 80, 443, 30414]
    }
  ]
}

### Subnets ###
module "service_lb_subnet" {
  count = var.make_new_network ? 1 : 0

  source  = "web-virtua-oci-multi-account-modules/subnet/oci"
  version = ">= 1.0.0"

  name           = "${var.cluster_name}-service-lb"
  cidr_block     = var.cidr_blocks.service_lb
  dns_label      = "tfservlb"
  vcn_id         = module.create_vcn[0].vcn_id
  compartment_id = var.compartment_id
  route_table_id = module.create_vcn[0].public_route_table_id

  security_list_ids = [
    module.create_all_eggres[0].security_list_id,
    module.sec_list_service_lb[0].security_list_id
  ]
}

module "endpoint_subnet" {
  count = var.make_new_network ? 1 : 0

  source  = "web-virtua-oci-multi-account-modules/subnet/oci"
  version = ">= 1.0.0"

  name           = "${var.cluster_name}-endpoint"
  cidr_block     = var.cidr_blocks.endpoint
  dns_label      = "tfendp"
  vcn_id         = module.create_vcn[0].vcn_id
  compartment_id = var.compartment_id
  route_table_id = module.create_vcn[0].public_route_table_id

  security_list_ids = [
    module.create_all_eggres[0].security_list_id,
    module.create_sec_list_endpoint[0].security_list_id
  ]
}

module "node_pools_subnet" {
  count = var.make_new_network ? 1 : 0

  source  = "web-virtua-oci-multi-account-modules/subnet/oci"
  version = ">= 1.0.0"

  name           = "${var.cluster_name}-node-pools"
  cidr_block     = var.cidr_blocks.node_pools
  dns_label      = "tfnodes"
  vcn_id         = module.create_vcn[0].vcn_id
  compartment_id = var.compartment_id
  route_table_id = module.create_vcn[0].private_route_table_id

  security_list_ids = [
    module.create_all_eggres[0].security_list_id,
    module.create_sec_list_nodes[0].security_list_id
  ]
}
