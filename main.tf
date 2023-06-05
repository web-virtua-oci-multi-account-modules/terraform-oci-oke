data "oci_containerengine_node_pool_option" "oci_oke_node_pool_option" {
  node_pool_option_id = "all"
}

locals {
  tags_oke = {
    "tf-name"        = var.cluster_name
    "tf-type"        = "oke"
    "tf-compartment" = var.compartment_name
  }
}

resource "oci_containerengine_cluster" "create_oci_oke" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = var.make_new_network ? module.create_vcn[0].vcn_id : var.vcn_id

  endpoint_config {
    is_public_ip_enabled = var.is_public_ip_enabled
    subnet_id            = var.make_new_network ? module.endpoint_subnet[0].subnet_id : var.endpoint_subnet_id
    nsg_ids              = var.endpoint_nsg_ids
  }

  options {
    service_lb_subnet_ids = var.make_new_network ? [module.service_lb_subnet[0].subnet_id] : var.service_lb_subnets_ids

    add_ons {
      is_kubernetes_dashboard_enabled = var.is_kubernetes_dashboard_enabled
      is_tiller_enabled               = var.is_tiller_enabled
    }

    persistent_volume_config {
      freeform_tags = merge(var.tags_volume, var.use_tags_default ? {
        "tf-name"        = "${var.cluster_name}-volume"
        "tf-main"        = "oke"
        "tf-type"        = "volume"
        "tf-compartment" = var.compartment_name
      } : {})

      defined_tags = var.defined_tags_volume
    }

    service_lb_config {
      freeform_tags = merge(var.tags_service_lb, var.use_tags_default ? {
        "tf-name"        = "${var.cluster_name}-service-lb"
        "tf-main"        = "oke"
        "tf-type"        = "service-lb"
        "tf-compartment" = var.compartment_name
      } : {})

      defined_tags = var.defined_tags_service_lb
    }

    admission_controller_options {
      is_pod_security_policy_enabled = var.is_pod_security_policy_enabled
    }

    dynamic "kubernetes_network_config" {
      for_each = var.kubernetes_network_config != null ? [1] : []

      content {
        pods_cidr     = var.kubernetes_network_config.pods_cidr
        services_cidr = var.kubernetes_network_config.services_cidr
      }
    }
  }

  freeform_tags = merge(var.tags, var.use_tags_default ? local.tags_oke : {})
  defined_tags  = var.defined_tags

  kms_key_id = var.kms_key_id
  type       = var.cluster_type

  dynamic "cluster_pod_network_options" {
    for_each = var.pod_network_options_cni_type != null ? [1] : []

    content {
      cni_type = var.pod_network_options_cni_type
    }
  }

  dynamic "image_policy_config" {
    for_each = var.image_policy_config != null ? [1] : []

    content {
      is_policy_enabled = var.image_policy_config.is_policy_enabled

      key_details {
        kms_key_id = var.image_policy_config.kms_key_id
      }
    }
  }
}

resource "oci_containerengine_node_pool" "create_oke_node_pools" {
  for_each = { for index, node_pool in var.node_pools : index => node_pool }

  cluster_id          = oci_containerengine_cluster.create_oci_oke.id
  compartment_id      = each.value.compartment_id != null ? each.value.compartment_id : var.compartment_id
  name                = each.value.name
  kubernetes_version  = try(each.value.kubernetes_version, var.kubernetes_version)
  node_shape          = each.value.node_shape
  ssh_public_key      = each.value.ssh_public_key != null ? each.value.ssh_public_key : var.ssh_keys_all_nodes
  node_metadata       = each.value.node_metadata
  quantity_per_subnet = each.value.quantity_per_subnet
  subnet_ids          = each.value.subnet_ids

  node_shape_config {
    memory_in_gbs = each.value.shape_memory_in_gbs
    ocpus         = each.value.shape_ocpus
  }

  node_config_details {
    placement_configs {
      availability_domain     = each.value.placement_ad
      subnet_id               = var.make_new_network ? module.node_pools_subnet[0].subnet_id : each.value.placement_subnet_id
      capacity_reservation_id = each.value.placement_capacity_reserva_id

      fault_domains = each.value.placement_fault_domains

      dynamic "preemptible_node_config" {
        for_each = each.value.preemptible_node != null ? [1] : []

        content {
          preemption_action {
            type                    = each.value.preemptible_node.type
            is_preserve_boot_volume = each.value.preemptible_node.is_preserve_boot_volumes
          }
        }
      }
    }

    size         = each.value.nodes_qtd
    defined_tags = each.value.defined_tags

    freeform_tags = merge(each.value.tags, var.use_tags_default ? {
      "tf-name"        = each.value.name
      "tf-main"        = "oke"
      "tf-cluster"     = var.cluster_name
      "tf-type"        = "node-pool"
      "tf-compartment" = var.compartment_name
    } : {})

    kms_key_id                          = each.value.kms_key_id
    is_pv_encryption_in_transit_enabled = each.value.is_pv_encryption_in_transit_enabled
    nsg_ids                             = each.value.nsg_ids

    dynamic "node_pool_pod_network_option_details" {
      for_each = each.value.node_pool_pod_network_option != null ? [1] : []

      content {
        cni_type          = each.value.node_pool_pod_network_option.cni_type
        max_pods_per_node = each.value.node_pool_pod_network_option.max_pods_per_node
        pod_nsg_ids       = each.value.node_pool_pod_network_option.pod_nsg_ids
        pod_subnet_ids    = each.value.node_pool_pod_network_option.pod_subnet_ids
      }
    }
  }

  node_source_details {
    boot_volume_size_in_gbs = each.value.node_volume_size
    source_type             = each.value.node_source_type
    image_id                = try(each.value.node_shape, null) != "VM.Standard.A1.Flex" ? element([for source in data.oci_containerengine_node_pool_option.oci_oke_node_pool_option.sources : source.image_id if length(regexall("Oracle-Linux-7.9-20[0-9]*.*", source.source_name)) > 0], 0) : element([for source in data.oci_containerengine_node_pool_option.oci_oke_node_pool_option.sources : source.image_id if length(regexall("Oracle-Linux-7.9-aarch64-20[0-9]*.*", source.source_name)) > 0], 0)
  }

  initial_node_labels {
    key   = "oke"
    value = each.value.name
  }

  dynamic "node_eviction_node_pool_settings" {
    for_each = each.value.node_eviction_node_pool != null ? [1] : []

    content {
      eviction_grace_duration              = each.value.node_eviction_node_pool_settings.eviction_grace_duration
      is_force_delete_after_grace_duration = each.value.node_eviction_node_pool_settings.is_force_delete_after_grace_duration
    }
  }
}
