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

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.location
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  maximum_length          = each.value.max_length
  instance_resource       = var.instance_resource
  use_azure_region_abbr   = var.use_azure_region_abbr
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = module.resource_names["resource_group"].standard
  location = var.location

  tags = merge(var.tags, { resource_name = module.resource_names["resource_group"].standard })
}

module "postgresql_server" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/postgresql_server/azurerm"
  version = "~> 1.0"

  name                = module.resource_names["postgresql_server"].standard
  resource_group_name = module.resource_group.name
  location            = var.location

  create_mode      = var.create_mode
  postgres_version = var.postgres_version
  sku_name         = var.sku_name
  storage_mb       = var.storage_mb
  storage_tier     = var.storage_tier

  identity_ids = var.identity_ids

  authentication         = var.authentication
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = var.public_network_access_enabled

  high_availability = var.high_availability

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  maintenance_window = var.maintenance_window

  source_server_id = var.source_server_id
  zone             = var.zone

  tags = merge(var.tags, { resource_name = module.resource_names["postgresql_server"].standard })
}

module "postgresql_server_configuration" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/postgresql_server_configuration/azurerm"
  version = "~> 1.0"

  for_each = var.server_configuration

  postgresql_server_id = module.postgresql_server.id

  configuration_key   = each.key
  configuration_value = each.value
}

module "postgresql_server_ad_administrator" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/postgresql_server_ad_administrator/azurerm"
  version = "~> 1.0"

  count = (var.ad_administrator != null) ? 1 : 0

  postgresql_server_name = module.postgresql_server.name
  resource_group_name    = module.resource_group.name

  tenant_id = var.ad_administrator.tenant_id
  object_id = var.ad_administrator.object_id

  principal_name = var.ad_administrator.principal_name
  principal_type = var.ad_administrator.principal_type
}

module "private_endpoint" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_endpoint/azurerm"
  version = "~> 1.0"

  count = var.public_network_access_enabled ? 0 : 1

  # endpoint_name                   = local.endpoint_name
  endpoint_name                   = module.resource_names["private_endpoint"].standard
  # resource_group_name             = local.resource_group_name
  resource_group_name  = module.resource_names["resource_group"].standard
  region                          = var.location
  subnet_id                       = var.subnet_id
  private_dns_zone_group_name     = var.private_dns_zone_group_name
  private_dns_zone_ids            = var.private_dns_zone_ids
  is_manual_connection            = var.is_manual_connection
  private_connection_resource_id  = module.postgresql_server.id
  subresource_names               = var.subresource_names
  request_message                 = var.request_message
  tags                            = local.private_endpoint_tags
  private_service_connection_name = module.resource_names["private_service_connection"].standard
  # resource_name                   = module.resource_names["private_endpoint"].standard

  # Do NOT set private_connection_resource_alias at all
  # depends_on = [module.postgresql_server]
}

