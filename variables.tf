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

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object({
    name       = string
    max_length = optional(number, 60)
  }))

  default = {
    postgresql_server = {
      name       = "psql"
      max_length = 60
    }
    private_endpoint = {
      name       = "pe"
      max_length = 80
    }
    private_service_connection = {
      name       = "pesc"
      max_length = 80
    }
    resource_group = {
      name       = "rg"
      max_length = 60
    }
  }
}

variable "instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  default     = 0

  validation {
    condition     = var.instance_env >= 0 && var.instance_env <= 999
    error_message = "Instance number should be between 0 to 999."
  }
}

variable "instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  default     = 0

  validation {
    condition     = var.instance_resource >= 0 && var.instance_resource <= 100
    error_message = "Instance number should be between 0 to 100."
  }
}

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "launch"
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "database"
}

variable "class_env" {
  type        = string
  description = "(Required) Environment where resource is going to be deployed. For example. dev, qa, uat"
  nullable    = false
  default     = "dev"

  validation {
    condition     = length(regexall("\\b \\b", var.class_env)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

variable "use_azure_region_abbr" {
  description = "Abbreviate the region in the resource names"
  type        = bool
  default     = true
}

variable "location" {
  description = "Location of the Postgres Flexible Server"
  type        = string
  default     = "eastus"
}

variable "sku_name" {
  description = "The name of the SKU used by this Postgres Flexible Server"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "create_mode" {
  description = "The creation mode. Possible values are Default, GeoRestore, PointInTimeRestore, Replica, and Update"
  type        = string
  default     = "Default"

  validation {
    condition     = can(regex("^(Default|GeoRestore|PointInTimeRestore|Replica|Update)$", var.create_mode))
    error_message = "Invalid create_mode value"
  }
}

variable "postgres_version" {
  description = "Version of the Postgres Flexible Server. Required when `create_mode` is Default"
  type        = string
  default     = "16"

  validation {
    condition     = can(regex("^[0-9]{2}$", var.postgres_version))
    error_message = "Invalid version value"
  }
}

variable "server_configuration" {
  description = "Map of configurations to apply to the postgres flexible server"
  type        = map(string)
  default     = {}
}

variable "delegated_subnet_id" {
  description = "The ID of the subnet to which the Postgres Flexible Server is delegated"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone. Required when `delegated_subnet_id` is set"
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is allowed for this server"
  type        = bool
  default     = false
}

variable "authentication" {
  description = <<-EOT
    active_directory_auth_enabled = Whether or not Active Directory authentication is enabled for this server
    password_auth_enabled         = Whether or not password authentication is enabled for this server
    tenant_id                     = The tenant ID of the Active Directory to use for authentication
  EOT
  type = object({
    active_directory_auth_enabled = optional(bool)
    password_auth_enabled         = optional(bool)
    tenant_id                     = optional(string)
  })
  default = null
}

variable "ad_administrator" {
  description = <<-EOT
    tenant_id      = The tenant ID of the AD administrator
    object_id      = The object ID of the AD administrator
    principal_name = The name of the princiapl to assign as AD administrator
    principal_type = The type of princiapl to assign as AD administrator
  EOT
  type = object({
    tenant_id      = string
    object_id      = string
    principal_name = string
    principal_type = string
  })
  default = null

  validation {
    condition     = var.ad_administrator == null || can(regex("^(Group|ServicePrincipal|User)$", var.ad_administrator.principal_type))
    error_message = "Principal type must be one of 'Group', 'ServicePrincipal, 'User'"
  }
}

variable "administrator_login" {
  description = <<-EOT
    The administrator login for the Postgres Flexible Server.
    Required when `create_mode` is Default and `authentication.password_auth_enabled` is true
  EOT
  type        = string
  default     = null
}

variable "administrator_password" {
  description = <<-EOT
    The administrator password for the Postgres Flexible Server.
    Required when `create_mode` is Default and `authentication.password_auth_enabled` is true
  EOT
  type        = string
  default     = null
}

variable "backup_retention_days" {
  description = "The backup retention days for the Postgres Flexible Server, between 7 and 35 days"
  type        = number
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  description = "Whether or not geo-redundant backups are enabled for this server"
  type        = bool
  default     = false
}

variable "zone" {
  description = "The zone of the Postgres Flexible Server"
  type        = string
  default     = null

  validation {
    condition     = var.zone == null || can(regex("^[0-9]$", var.zone))
    error_message = "Invalid value for `zone`"
  }
}

variable "high_availability" {
  description = <<-EOT
    mode                      = The high availability mode. Possible values are SameZone or ZoneRedundant
    standby_availability_zone = The availability zone for the standby server
  EOT
  type = object({
    mode                      = string
    standby_availability_zone = optional(string)
  })
  default = null

  validation {
    condition     = var.high_availability == null || can(regex("^(SameZone|ZoneRedundant)$", var.high_availability.mode))
    error_message = "Invalid high_availability.mode value. Must be SameZone or ZoneRedundant"
  }
  validation {
    condition     = var.high_availability == null || can(regex("^[0-9]$", var.high_availability.standby_availability_zone))
    error_message = "Invalid value for standby_availability_zone"
  }
}

variable "identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned"
  type        = list(string)
  default     = null
}

variable "maintenance_window" {
  description = <<-EOT
    The maintenance window of the Postgres Flexible Server
    day_of_week = The day of the week when maintenance should be performed
    start_hour   = The start hour of the maintenance window
    start_minute = The start minute of the maintenance window
  EOT
  type = object({
    day_of_week  = optional(string, 0)
    start_hour   = optional(number, 0)
    start_minute = optional(number, 0)
  })
  default = {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }

  validation {
    condition     = var.maintenance_window.day_of_week >= 0 && var.maintenance_window.day_of_week <= 6
    error_message = "Invalid maintenance_window.day_of_week value"
  }
  validation {
    condition     = var.maintenance_window.start_hour >= 0 && var.maintenance_window.start_hour <= 23
    error_message = "maintenance_window.start_hour must be between 0 and 23"
  }
  validation {
    condition     = var.maintenance_window.start_minute >= 0 && var.maintenance_window.start_minute <= 59
    error_message = "maintenance_window.start_minute must be between 0 and 59"
  }
}

variable "source_server_id" {
  description = "The ID of the source Postgres Flexible Server to restore from. Required when `create_mode` is GeoRestore, PointInTimeRestore, or Replica"
  type        = string
  default     = null
}

variable "storage_mb" {
  description = "The storage capacity of the Postgres Flexible Server in megabytes"
  type        = number
  default     = 32768

  validation {
    condition = contains([
      32768,
      65536,
      131072,
      262144,
      524288,
      1048576,
      2097152,
      4193280,
      4194304,
      8388608,
      16777216,
      33553408
    ], var.storage_mb)
    error_message = "Invalid storage_mb value"
  }
}

variable "storage_tier" {
  description = "The storage tier of the Postgres Flexible Server. Default value based on `storage_mb`"
  type        = string
  default     = null

  validation {
    condition     = var.storage_tier == null || can(regex("^(P4|P6|P10|P15|P20|P30|P40|P50|P60|P70|P80)$", var.storage_tier))
    error_message = "Invalid storage_tier value"
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "create_private_endpoint" {
  description = "Whether or not to create a Private Endpoint for the Postgres Flexible Server"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "The ID of the subnet to which the Postgres Flexible Server private endpoint is connected"
  type        = string
  default     = null
}

variable "private_endpoint_dns_zone_ids" {
  description = "A list of Private DNS Zone IDs to link with the Private Endpoint."
  type        = list(string)
  default     = []
}

# https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns
variable "private_endpoint_dns_zone_group_name" {
  description = "Specifies the Name of the Private DNS Zone Group."
  type        = string
  default     = "postgresqlServer"
}

variable "private_endpoint_is_manual_connection" {
  description = <<EOT
    Does the Private Endpoint require Manual Approval from the remote resource owner? Changing this forces a new resource
    to be created.
  EOT
  type        = bool
  default     = false
}


variable "private_endpoint_subresource_names" {
  description = <<EOT
    A list of subresource names which the Private Endpoint is able to connect to. subresource_names corresponds to group_id.
    Possible values are detailed in the product documentation in the Subresources column.
    https://docs.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource
  EOT
  type        = list(string)
  default     = ["postgresqlServer"]
}

variable "private_endpoint_request_message" {
  description = <<EOT
    A message passed to the owner of the remote resource when the private endpoint attempts to establish the connection
    to the remote resource. The request message can be a maximum of 140 characters in length.
    Only valid if `is_manual_connection=true`
  EOT
  type        = string
  default     = ""
}
