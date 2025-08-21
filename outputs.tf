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

output "private_dns_zone_ids" {
  value = module.postgresql_server.private_dns_zone_ids
}

output "source_server_id" {
  value = module.postgresql_server.source_server_id
}

output "server_configuration" {
  value = { for config in module.postgresql_server_configuration : config.name => config.value }
}

output "postgresql_server_id" {
  value = module.postgresql_server.id
}
