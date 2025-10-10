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

data "azurerm_client_config" "client" {}

data "azuread_service_principal" "client" {
  count = var.use_service_principal ? 1 : 0

  object_id = data.azurerm_client_config.client.object_id
}

data "azuread_user" "client" {
  count = var.use_service_principal ? 0 : 1

  object_id = data.azurerm_client_config.client.object_id
}

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
}

module "network_resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = module.resource_names["resource_group"].minimal_random_suffix
  location = var.location

  tags = merge(var.tags, { resource_name = module.resource_names["resource_group"].standard })
}

module "virtual_network" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/virtual_network/azurerm"
  version = "~> 3.0"

  vnet_name           = module.resource_names["virtual_network"].minimal_random_suffix
  resource_group_name = module.network_resource_group.name
  vnet_location       = var.location

  address_space = [var.vnet_address_space]
  subnets = {
    private-endpoint-subnet = {
      prefix = var.vnet_address_space
    }
  }

  tags = merge(var.tags, { resource_name = module.resource_names["virtual_network"].standard })

  depends_on = [module.network_resource_group]
}

module "private_dns_zone" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_dns_zone/azurerm"
  version = "~> 1.0"

  zone_name           = "privatelink.postgres.database.azure.com"
  resource_group_name = module.network_resource_group.name

  tags = var.tags

  depends_on = [module.network_resource_group]
}

module "private_dns_zone_vnet_link" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_dns_vnet_link/azurerm"
  version = "~> 1.0"

  link_name             = replace(module.private_dns_zone.zone_name, ".", "-")
  resource_group_name   = module.network_resource_group.name
  private_dns_zone_name = module.private_dns_zone.zone_name
  virtual_network_id    = module.virtual_network.vnet_id
  registration_enabled  = false

  tags = var.tags

  depends_on = [module.network_resource_group, module.private_dns_zone, module.virtual_network]
}

# the vnet cannot be destroyed for some time after terraform thinks the postgresql server is destroyed
resource "time_sleep" "wait_after_destroy" {
  destroy_duration = var.time_to_wait_after_destroy

  depends_on = [module.network_resource_group, module.virtual_network, module.private_dns_zone, module.private_dns_zone_vnet_link]
}

module "postgresql_server" {
  source = "../.."

  resource_names_map      = var.resource_names_map
  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  location                = var.location
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource

  create_mode      = var.create_mode
  postgres_version = var.postgres_version
  sku_name         = var.sku_name
  storage_mb       = var.storage_mb
  storage_tier     = var.storage_tier

  server_configuration = var.server_configuration

  identity_ids = var.identity_ids

  # use AD auth on the tenant being deployed to unless otherwise specified
  authentication = coalesce(var.authentication, {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
    tenant_id                     = data.azurerm_client_config.client.tenant_id
  })

  # assign administrator to current user unless otherwise specified
  ad_administrator = coalesce(var.ad_administrator, {
    tenant_id = data.azurerm_client_config.client.tenant_id
    object_id = data.azurerm_client_config.client.object_id

    principal_name = var.use_service_principal ? data.azuread_service_principal.client[0].display_name : data.azuread_user.client[0].user_principal_name
    principal_type = var.use_service_principal ? "ServicePrincipal" : "User"
  })

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  create_private_endpoint       = var.create_private_endpoint
  private_endpoint_subnet_id    = module.virtual_network.subnet_map["private-endpoint-subnet"].id
  private_endpoint_dns_zone_ids = [module.private_dns_zone.id]

  public_network_access_enabled = var.public_network_access_enabled

  high_availability = var.high_availability

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  maintenance_window = var.maintenance_window

  source_server_id = var.source_server_id
  zone             = var.zone

  tags = merge(var.tags, { resource_name = module.resource_names["postgresql_server"].standard })

  depends_on = [module.network_resource_group, module.virtual_network, module.private_dns_zone, time_sleep.wait_after_destroy]
}
