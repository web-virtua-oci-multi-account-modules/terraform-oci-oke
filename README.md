# OCI Cluster OKE for multiples accounts with Terraform module
* This module simplifies creating and configuring of Cluster OKE across multiple accounts on OCI

* Is possible use this module with one account using the standard profile or multi account using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Criate file provider.tf with the exemple code below:
```hcl
provider "oci" {
  alias   = "alias_profile_a"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.ssh_private_key_path
  region           = var.region
}

provider "oci" {
  alias   = "alias_profile_b"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.ssh_private_key_path
  region           = var.region
}
```


## Features enable of User configurations for this module:

- Cluster OKE
- Node pool OKE
- Virtual network
- Internet gateway
- NAT gateway
- Nervice gateway
- Route table
- Subnet
- Security list

## Usage exemples


### Create cluster OKE with network full

```hcl
module "oke_test_with_network" {
  source = "web-virtua-oci-multi-account-modules/oke/oci"

  cluster_name       = "tf-cluster-oke"
  compartment_id     = var.compartment_id
  kubernetes_version = "v1.26.2"
  make_new_network   = true

  cidr_blocks = {
    vcn        = "10.2.0.0/16"
    service_lb = "10.2.1.0/24"
    endpoint   = "10.2.2.0/24"
    node_pools = "10.2.3.0/24"
  }

  node_pools = [
    {
      name                = "tf-node-a1-flex-1"
      placement_ad        = data.oci_identity_availability_domain.ad1.name
      node_shape          = "VM.Standard.A1.Flex"
      shape_memory_in_gbs = 6
      shape_ocpus         = 1
      nodes_qtd           = 1
      node_volume_size    = 50
    }
  ]

  providers = {
    oci = oci.alias_profile_a
  }
}
```

### Create cluster OKE using network exists and two node pools with node images differents

```hcl
module "oke_test" {
  source = "web-virtua-oci-multi-account-modules/oke/oci"

  cluster_name       = "tf-cluster-oke"
  compartment_id     = var.compartment_id
  kubernetes_version = "v1.26.2"
  vcn_id             = var.vcn_id
  endpoint_subnet_id = var.endpoint_sububnet_public

  service_lb_subnets_ids = [
    var.service_lb_sububnet_public
  ]

  node_pools = [
    {
      name                = "tf-node-a1-flex-1"
      placement_ad        = data.oci_identity_availability_domain.ad1.name
      placement_subnet_id = var.sububnet_private_1_id
      node_shape          = "VM.Standard.A1.Flex"
      shape_memory_in_gbs = 6
      shape_ocpus         = 1
      nodes_qtd           = 1
      node_volume_size    = 50
    },
    {
      name                = "tf-node-e3-flex-1"
      placement_ad        = data.oci_identity_availability_domain.ad1.name
      placement_subnet_id = var.sububnet_private_1_id
      node_shape          = "VM.Standard.E3.Flex"
      shape_memory_in_gbs = 6
      shape_ocpus         = 1
      nodes_qtd           = 1
      node_volume_size    = 50
    }
  ]

  providers = {
    oci = oci.alias_profile_b
  }
}
```

## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| compartment_id | `string` | `-` | yes | Compartment ID | `-` |
| cluster_name | `string` | `tf-cluster-k8s` | no | Cluster name | `-` |
| vcn_id | `string` | `null` | no | VCN ID | `-` |
| kubernetes_version | `string` | `v1.25.4` | no | Kubernetes version | `-` |
| make_new_network | `bool` | `false` | no | If true, will be created a network full to use on cluster | `*`false <br> `*`true |
| is_public_ip_enabled | `bool` | `true` | no | If true, will be created a endpoint public IP | `*`false <br> `*`true |
| compartment_name | `string` | `null` | no | Compartment name | `-` |
| endpoint_subnet_id | `string` | `null` | no | Subnet ID cluster endpoint | `-` |
| endpoint_nsg_ids | `list(string)` | `null` | no | A list of the OCIDs of the network security groups (NSGs) to apply to the cluster endpoint | `-` |
| service_lb_subnets_ids | `list(string)` | `null` | no | Service LB subnets IDs to cluster | `-` |
| is_kubernetes_dashboard_enabled | `bool` | `true` | no | Enable kubernetes dashboard | `*`false <br> `*`true |
| is_tiller_enabled | `bool` | `true` | no | IF true, the tiller will be enabled | `*`false <br> `*`true |
| use_tags_default | `bool` | `true` | no | If true will be use the tags default to resources | `*`false <br> `*`true |
| tags | `map(any)` | `{}` | no | Tags to cluster | `-` |
| defined_tags | `map(any)` | `{}` | no | Defined tags to compartment | `-` |
| tags_volume | `map(any)` | `{}` | no | Tags to OKE volumes | `-` |
| defined_tags_volume | `map(any)` | `{}` | no | Defined tags to OKE volumes | `-` |
| tags_service_lb | `map(any)` | `{}` | no | Tags to OKE service lb | `-` |
| defined_tags_service_lb | `map(any)` | `{}` | no | Defined tags to OKE service lb | `-` |
| is_pod_security_policy_enabled | `bool` | `false` | no | If true enable the Pod Security Policy admission controller | `*`false <br> `*`true |
| kubernetes_network_config | `list(object)` | `null` | no | The CIDR block for Kubernetes pods, this is options. For pods_cidr defaults to 10.244.0.0/16 and for services_cidr defaults to 10.96.0.0/16 | `-` |
| pod_network_options_cni_type | `string` | `null` | no | The CNI used by the node pools of this cluster | `-` |
| kms_key_id | `string` | `null` | no | OCID of the KMS key to be used as the master encryption key for Kubernetes secret encryption | `-` |
| cluster_type | `string` | `null` | no | Type of cluster | `-` |
| image_policy_config | `list(object)` | `null` | no | Image verification policy for signature validation, for is_policy_enabled if true, the image verification policy is enabled to verify, for kms_key_id the image verification policy is enabled to verify | `-` |
| node_pools | `list(object)` | `[]` | no | Node pools configuration, the placement_subnet_id variable require one subnet, but isn't allowed use same subnet used on service_lb or endpoint subnet | `-` |
| cidr_blocks | `list(object)` | `object` | no | CIDR block to create network if necessary | `-` |


* Default cidr_blocks variable
```hcl
variable "cidr_blocks" {
  description = "CIDR block to create network if necessary"
  type = object({
    vcn        = string
    service_lb = string
    endpoint   = string
    node_pools = string
  })
  default = {
    vcn        = "10.2.0.0/16"
    service_lb = "10.2.1.0/24"
    endpoint   = "10.2.2.0/24"
    node_pools = "10.2.3.0/24"
  }
}
```

* Model of kubernetes_network_config variable
```hcl
variable "kubernetes_network_config" {
  description = "The CIDR block for Kubernetes pods, this is options. For pods_cidr defaults to 10.244.0.0/16 and for services_cidr defaults to 10.96.0.0/16"
  type = object({
    pods_cidr     = optional(string)
    services_cidr = optional(string)
  })
  default = {}
}
```

* Model of image_policy_config variable
```hcl
variable "image_policy_config" {
  description = "Image verification policy for signature validation, for is_policy_enabled if true, the image verification policy is enabled to verify, for kms_key_id the image verification policy is enabled to verify"
  type = object({
    is_policy_enabled = optional(bool)
    kms_key_id        = optional(list(string))
  })
  default = null
}

```

* Model of node_pools policies
```hcl
variable "node_pools" {
  description = "Node pools configuration, the placement_subnet_id variable require one subnet, but isn't allowed use same subnet used on service_lb or endpoint subnet"
  type = list(object({
    name                                = string
    compartment_id                      = optional(string)
    kubernetes_version                  = optional(string)
    node_shape                          = optional(string, "VM.Standard.A1.Flex")
    ssh_public_key                      = optional(string)
    node_metadata                       = optional(map(any))
    quantity_per_subnet                 = optional(number)
    subnet_ids                          = optional(list(string))
    shape_memory_in_gbs                 = optional(number)
    shape_ocpus                         = optional(number)
    placement_ad                        = string
    placement_subnet_id                 = optional(string)
    placement_capacity_reserva_id       = optional(string)
    placement_fault_domains             = optional(list(string))
    nodes_qtd                           = optional(number, 1)
    tags                                = optional(map(any))
    defined_tags                        = optional(map(any))
    node_volume_size                    = optional(number, 50)
    node_image_id                       = optional(string)
    node_source_type                    = optional(string, "IMAGE")
    kms_key_id                          = optional(string)
    is_pv_encryption_in_transit_enabled = optional(bool)
    nsg_ids                             = optional(list(string))
    node_pool_pod_network_option = optional(object({
      cni_type          = string
      max_pods_per_node = optional(number)
      pod_nsg_ids       = optional(list(string))
      pod_subnet_ids    = optional(list(string))
    }))
    preemptible_node = optional(object({
      type                    = string
      is_preserve_boot_volume = optional(bool)
    }))
    node_eviction_node_pool = optional(object({
      eviction_grace_duration              = optional(string)
      is_force_delete_after_grace_duration = optional(bool)
    }))
  }))
  default = [
    {
      name                = "tf-node-e3-flex-1"
      placement_ad        = data.oci_identity_availability_domain.ad1.name
      placement_subnet_id = var.sububnet_private_1_id
      node_shape          = "VM.Standard.E3.Flex"
      shape_memory_in_gbs = 6
      shape_ocpus         = 1
      nodes_qtd           = 1
      node_volume_size    = 50
    }
  ]
}
```


## Resources

| Name | Type |
|------|------|
| [oci_containerengine_cluster.create_oci_oke](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster) | resource |
| [oci_containerengine_node_pool.create_oke_node_pools](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_node_pool) | resource |
| [module.create_vcn](https://registry.terraform.io/modules/web-virtua-oci-multi-account-modules/vcn-full/oci/latest) | resource |
| [module.service_lb_subnet](https://registry.terraform.io/modules/web-virtua-oci-multi-account-modules/subnet/oci/latest) | resource |
| [module.endpoint_subnet](https://registry.terraform.io/modules/web-virtua-oci-multi-account-modules/subnet/oci/latest) | resource |
| [module.service_lb_subnet](https://registry.terraform.io/modules/web-virtua-oci-multi-account-modules/subnet/oci/latest) | resource |
| [module.node_pools_subnet](https://registry.terraform.io/modules/web-virtua-oci-multi-account-modules/subnet/oci/latest) | resource |
| [module.create_all_eggres](https://registry.terraform.io/modules/web-virtua-oci-multi-account-modules/security-list/oci/latest) | resource |
| [module.create_sec_list_endpoint](https://registry.terraform.io/modules/web-virtua-oci-multi-account-modules/security-list/oci/latest) | resource |
| [module.sec_list_service_lb](https://registry.terraform.io/modules/web-virtua-oci-multi-account-modules/security-list/oci/latest) | resource |
| [module.create_sec_list_nodes](https://registry.terraform.io/modules/web-virtua-oci-multi-account-modules/security-list/oci/latest) | resource |

## Outputs

| Name | Description |
|------|-------------|
| `oke` | Cluster OKE |
| `oke_id` | Cluster OKE ID |
| `node_pools` | OKE node pools |
| `vcn` | VCN |
| `vcn_id` | VCN ID |
| `internet_gateway` | Internet gateway |
| `internet_gateway_id` | Internet gateway ID |
| `nat_gateway` | NAT gateway |
| `nat_gateway_id` | NAT gateway ID |
| `service_gateway` | Service gateway |
| `service_gateway_id` | Service gateway ID |
| `public_route_table` | Public route table |
| `public_route_table_id` | Public route table ID |
| `private_route_table` | Private route table |
| `private_route_table_id` | Private route table ID |
| `public_service_lb_subnet` | Public subnets |
| `public_service_lb_subnet_id` | Public subnets ID |
| `public_endpoint_subnet` | Public endpoint subnets |
| `public_endpoint_subnet_id` | Public endpoint subnets ID |
| `private_node_pools_subnet` | Private node pools subn |
| `private_node_pools_subnet_id` | Private node pools subnets ID |
| `sec_list_all_eggres` | Security list all eggress |
| `sec_list_all_eggres_id` | Security list all eggress ID |
| `sec_list_endpoint` | Security list endpoint |
| `sec_list_endpoint_id` | Security list endpoint ID |
| `sec_list_service_lb` | Security list service lb |
| `sec_list_service_lb_id` | Security list service lb ID |
| `sec_list_nodes` | Security list nodes |
| `sec_list_nodes_id` | Security list nodes ID |
