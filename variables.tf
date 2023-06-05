variable "compartment_id" {
  description = "Compartment ID"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
  default     = "tf-cluster-k8s"
}

variable "vcn_id" {
  description = "VCN ID"
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "v1.25.4"
}

variable "make_new_network" {
  description = "If true, will be created a network full to use on cluster"
  type        = bool
  default     = false
}

variable "is_public_ip_enabled" {
  description = "If true, will be created a endpoint public IP"
  type        = bool
  default     = true
}

variable "compartment_name" {
  description = "Compartment name"
  type        = string
  default     = null
}

variable "endpoint_subnet_id" {
  description = "Subnet ID cluster endpoint"
  type        = string
  default     = null
}

variable "endpoint_nsg_ids" {
  description = "A list of the OCIDs of the network security groups (NSGs) to apply to the cluster endpoint"
  type        = list(string)
  default     = null
}

variable "service_lb_subnets_ids" {
  description = "Service LB subnets IDs to cluster"
  type        = list(string)
  default     = null
}

variable "is_kubernetes_dashboard_enabled" {
  description = "Enable kubernetes dashboard"
  type        = bool
  default     = true
}

variable "is_tiller_enabled" {
  description = "IF true, the tiller will be enabled"
  type        = bool
  default     = true
}

variable "use_tags_default" {
  description = "If true will be use the tags default to resources"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to OKE"
  type        = map(any)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to OKE"
  type        = map(any)
  default     = null
}

variable "tags_volume" {
  description = "Tags to OKE volumes"
  type        = map(any)
  default     = {}
}

variable "defined_tags_volume" {
  description = "Defined tags to OKE volumes"
  type        = map(any)
  default     = null
}

variable "tags_service_lb" {
  description = "Tags to OKE service lb"
  type        = map(any)
  default     = {}
}

variable "defined_tags_service_lb" {
  description = "Defined tags to OKE service lb"
  type        = map(any)
  default     = null
}

variable "is_pod_security_policy_enabled" {
  description = "If true enable the Pod Security Policy admission controller"
  type        = bool
  default     = false
}

variable "kubernetes_network_config" {
  description = "The CIDR block for Kubernetes pods, this is options. For pods_cidr defaults to 10.244.0.0/16 and for services_cidr defaults to 10.96.0.0/16"
  type = object({
    pods_cidr     = optional(string)
    services_cidr = optional(string)
  })
  default = null
}

variable "pod_network_options_cni_type" {
  description = "The CNI used by the node pools of this cluster"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "OCID of the KMS key to be used as the master encryption key for Kubernetes secret encryption"
  type        = string
  default     = null
}

variable "cluster_type" {
  description = "Type of cluster"
  type        = string
  default     = null
}

variable "image_policy_config" {
  description = "Image verification policy for signature validation, for is_policy_enabled if true, the image verification policy is enabled to verify, for kms_key_id the image verification policy is enabled to verify"
  type = object({
    is_policy_enabled = optional(bool)
    kms_key_id        = optional(list(string))
  })
  default = null
}

variable "ssh_keys_all_nodes" {
  description = "String with keys SSH for all nodes that not set ssh public key, one per line"
  type        = string
  default     = null
}

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
  default = []
}

variable "cidr_blocks" {
  description = "CIDR block to create network if necessary"
  type = object({
    vcn        = string
    service_lb = string
    endpoint   = string
    node_pools = string
  })
  default = {
    vcn        = "10.1.0.0/16"
    service_lb = "10.1.11.0/24"
    endpoint   = "10.1.12.0/24"
    node_pools = "10.1.13.0/24"
  }
}
