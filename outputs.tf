// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

output "id" {
  value = module.postgresql_server.id
}

output "name" {
  value = module.postgresql_server.name
}

output "fqdn" {
  value = module.postgresql_server.fqdn
}

output "resource_group_name" {
  value = module.resource_group.name
}

output "admin_tenant_id" {
  value = module.postgresql_server_ad_administrator[0].tenant_id
}

output "admin_object_id" {
  value = module.postgresql_server_ad_administrator[0].object_id
}

output "admin_principal_name" {
  value = module.postgresql_server_ad_administrator[0].principal_name
}

output "delegated_subnet_id" {
  value = module.postgresql_server.delegated_subnet_id
}

output "private_dns_zone_id" {
  value = module.postgresql_server.private_dns_zone_id
}

output "source_server_id" {
  value = module.postgresql_server.source_server_id
}

output "server_configuration" {
  value = { for config in module.postgresql_server_configuration : config.name => config.value }
}

output "diagnostic_setting_id" {
  description = "ID of the PostgreSQL diagnostic setting, or null when diagnostic settings are disabled."
  value       = try(module.postgresql_server_diagnostic_setting[0].id, null)
}

output "diagnostic_setting_name" {
  description = "Name of the PostgreSQL diagnostic setting, or null when diagnostic settings are disabled."
  value       = try(module.postgresql_server_diagnostic_setting[0].name, null)
}

output "diagnostic_log_analytics_workspace_id" {
  description = "Log Analytics workspace ID receiving PostgreSQL diagnostic logs, or null when diagnostic settings are disabled."
  value       = var.log_analytics_workspace_id
}

output "diagnostic_log_categories" {
  description = "PostgreSQL log categories enabled by this module, or an empty list when diagnostic settings are disabled."
  value       = var.log_analytics_workspace_id == null ? [] : var.diagnostic_log_categories
}
