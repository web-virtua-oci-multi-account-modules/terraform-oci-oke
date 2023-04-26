output "oke" {
  description = "Cluster OKE"
  value       = oci_containerengine_cluster.create_oci_oke
}

output "oke_id" {
  description = "Cluster OKE ID"
  value       = oci_containerengine_cluster.create_oci_oke.id
}

output "node_pools" {
  description = "OKE node pools"
  value       = try(oci_containerengine_node_pool.create_oke_node_pools, null)
}

#-------------------------------------------#
#-----------------Networks------------------#
output "vcn" {
  description = "VCN"
  value       = try(module.create_vcn.vcn, null)
}

output "vcn_id" {
  description = "VCN ID"
  value       = try(module.create_vcn.vcn_id, null)
}

output "internet_gateway" {
  description = "Internet gateway"
  value       = try(module.create_vcn.internet_gateway, null)
}

output "internet_gateway_id" {
  description = "Internet gateway ID"
  value       = try(module.create_vcn.internet_gateway_id, null)
}

output "nat_gateway" {
  description = "NAT gateway"
  value       = try(module.create_vcn.nat_gateway, null)
}

output "nat_gateway_id" {
  description = "NAT gateway ID"
  value       = try(module.create_vcn.nat_gateway_id, null)
}

output "service_gateway" {
  description = "Service gateway"
  value       = try(module.create_vcn.service_gateway, null)
}

output "service_gateway_id" {
  description = "Service gateway ID"
  value       = try(module.create_vcn.service_gateway_id, null)
}

output "public_route_table" {
  description = "Public route table"
  value       = try(module.create_vcn.public_route_table, null)
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = try(module.create_vcn.public_route_table_id, null)
}

output "private_route_table" {
  description = "Private route table"
  value       = try(module.create_vcn.private_route_table, null)
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = try(module.create_vcn.private_route_table_id, null)
}

output "public_service_lb_subnet" {
  description = "Public subnets"
  value       = try(module.service_lb_subnet.subnet, null)
}

output "public_service_lb_subnet_id" {
  description = "Public subnets ID"
  value       = try(module.service_lb_subnet.subnet_id, null)
}

output "public_endpoint_subnet" {
  description = "Public endpoint subnets"
  value       = try(module.endpoint_subnet.subnet, null)
}

output "public_endpoint_subnet_id" {
  description = "Public endpoint subnets ID"
  value       = try(module.endpoint_subnet.subnet_id, null)
}

output "private_node_pools_subnet" {
  description = "Private node pools subnet"
  value       = try(module.node_pools_subnet.subnet, null)
}

output "private_node_pools_subnet_id" {
  description = "Private node pools subnet ID"
  value       = try(module.node_pools_subnet.subnet_id, null)
}

#-------------------------------------------#
#--------------Security List----------------#
output "sec_list_all_eggres" {
  description = "Security list all eggress"
  value = try(module.create_all_eggres.security_list, null)
}

output "sec_list_all_eggres_id" {
  description = "Security list all eggress ID"
  value = try(module.create_all_eggres.security_list_id, null)
}

output "sec_list_endpoint" {
  description = "Security list endpoint"
  value = try(module.create_sec_list_endpoint.security_list, null)
}

output "sec_list_endpoint_id" {
  description = "Security list endpoint ID"
  value = try(module.create_sec_list_endpoint.security_list_id, null)
}

output "sec_list_service_lb" {
  description = "Security list service lb"
  value = try(module.sec_list_service_lb.security_list, null)
}

output "sec_list_service_lb_id" {
  description = "Security list service lb ID"
  value = try(module.sec_list_service_lb.security_list_id, null)
}

output "sec_list_nodes" {
  description = "Security list nodes"
  value = try(module.create_sec_list_nodes.security_list, null)
}

output "sec_list_nodes_id" {
  description = "Security list nodes ID"
  value = try(module.create_sec_list_nodes.security_list_id, null)
}
