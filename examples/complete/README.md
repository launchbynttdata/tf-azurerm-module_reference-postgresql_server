# complete

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.113 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.116.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.12.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm | ~> 1.0 |
| <a name="module_virtual_network"></a> [virtual\_network](#module\_virtual\_network) | terraform.registry.launch.nttdata.com/module_primitive/virtual_network/azurerm | ~> 3.0 |
| <a name="module_private_dns_zone"></a> [private\_dns\_zone](#module\_private\_dns\_zone) | terraform.registry.launch.nttdata.com/module_primitive/private_dns_zone/azurerm | ~> 1.0 |
| <a name="module_postgresql_server"></a> [postgresql\_server](#module\_postgresql\_server) | ./../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [time_sleep.wait_after_destroy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azurerm_client_config.client](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object({<br>    name       = string<br>    max_length = optional(number, 60)<br>  }))</pre> | <pre>{<br>  "postgresql_server": {<br>    "max_length": 60,<br>    "name": "psql"<br>  },<br>  "resource_group": {<br>    "max_length": 60,<br>    "name": "rg"<br>  },<br>  "virtual_network": {<br>    "max_length": 60,<br>    "name": "vnet"<br>  }<br>}</pre> | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Number that represents the instance of the environment. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Number that represents the instance of the resource. | `number` | `0` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | `"database"` | no |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | (Required) Environment where resource is going to be deployed. For example. dev, qa, uat | `string` | `"dev"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of the Postgres Flexible Server | `string` | `"eastus"` | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | Address space of the example vnet | `string` | `"10.0.200.0/24"` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Suffix of the private dns zone name | `string` | `"launchdso.postgres.database.azure.com"` | no |
| <a name="input_time_to_wait_after_destroy"></a> [time\_to\_wait\_after\_destroy](#input\_time\_to\_wait\_after\_destroy) | time to wait before destroying the virtual network | `string` | `"90s"` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The name of the SKU used by this Postgres Flexible Server | `string` | `"B_Standard_B1ms"` | no |
| <a name="input_create_mode"></a> [create\_mode](#input\_create\_mode) | The creation mode. Possible values are Default, GeoRestore, PointInTimeRestore, Replica, and Update | `string` | `"Default"` | no |
| <a name="input_postgres_version"></a> [postgres\_version](#input\_postgres\_version) | Version of the Postgres Flexible Server. Required when `create_mode` is Default | `string` | `"16"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether or not public network access is allowed for this server | `bool` | `false` | no |
| <a name="input_authentication"></a> [authentication](#input\_authentication) | active\_directory\_auth\_enabled = Whether or not Active Directory authentication is enabled for this server<br>password\_auth\_enabled         = Whether or not password authentication is enabled for this server<br>tenant\_id                     = The tenant ID of the Active Directory to use for authentication | <pre>object({<br>    active_directory_auth_enabled = optional(bool)<br>    password_auth_enabled         = optional(bool)<br>    tenant_id                     = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | The administrator login for the Postgres Flexible Server.<br>Required when `create_mode` is Default and `authentication.password_auth_enabled` is true | `string` | `null` | no |
| <a name="input_administrator_password"></a> [administrator\_password](#input\_administrator\_password) | The administrator password for the Postgres Flexible Server.<br>Required when `create_mode` is Default and `authentication.password_auth_enabled` is true | `string` | `null` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | The backup retention days for the Postgres Flexible Server, between 7 and 35 days | `number` | `7` | no |
| <a name="input_geo_redundant_backup_enabled"></a> [geo\_redundant\_backup\_enabled](#input\_geo\_redundant\_backup\_enabled) | Whether or not geo-redundant backups are enabled for this server | `bool` | `false` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The zone of the Postgres Flexible Server | `string` | `null` | no |
| <a name="input_high_availability"></a> [high\_availability](#input\_high\_availability) | mode                      = The high availability mode. Possible values are SameZone or ZoneRedundant<br>standby\_availability\_zone = The availability zone for the standby server | <pre>object({<br>    mode                      = string<br>    standby_availability_zone = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of User Assigned Managed Identity IDs to be assigned | `list(string)` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | The maintenance window of the Postgres Flexible Server<br>day\_of\_week = The day of the week when maintenance should be performed<br>start\_hour   = The start hour of the maintenance window<br>start\_minute = The start minute of the maintenance window | <pre>object({<br>    day_of_week  = optional(string, 0)<br>    start_hour   = optional(number, 0)<br>    start_minute = optional(number, 0)<br>  })</pre> | <pre>{<br>  "day_of_week": 0,<br>  "start_hour": 0,<br>  "start_minute": 0<br>}</pre> | no |
| <a name="input_source_server_id"></a> [source\_server\_id](#input\_source\_server\_id) | The ID of the source Postgres Flexible Server to restore from. Required when `create_mode` is GeoRestore, PointInTimeRestore, or Replica | `string` | `null` | no |
| <a name="input_storage_mb"></a> [storage\_mb](#input\_storage\_mb) | The storage capacity of the Postgres Flexible Server in megabytes | `number` | `32768` | no |
| <a name="input_storage_tier"></a> [storage\_tier](#input\_storage\_tier) | The storage tier of the Postgres Flexible Server. Default value based on `storage_mb` | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_postgres_id"></a> [postgres\_id](#output\_postgres\_id) | n/a |
| <a name="output_postgres_name"></a> [postgres\_name](#output\_postgres\_name) | n/a |
| <a name="output_postgres_fqdn"></a> [postgres\_fqdn](#output\_postgres\_fqdn) | n/a |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
