# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Local values for resource names and tags
locals {
  resource_group_name             = module.resource_names["resource_group"].standard
  endpoint_name                   = module.resource_names["private_endpoint"].standard
  private_endpoint_tags = merge({ resource_name = local.endpoint_name }, local.default_tags, var.tags)
  private_service_connection_name = module.resource_names["private_service_connection"].standard
  
    default_tags = {
    "provisioner" = "terraform"
  }

  

  # subresource_names                = ["postgresqlServer"]
}

 