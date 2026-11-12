# https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-server-parameters
# Keep server_configuration minimal for CI: log_connections teardown often hits ServerIsBusy
# on private-endpoint examples (VNet + PE destroy races the flexible server).
server_configuration = {
  "backslash_quote" = "on"
}

# uncomment when running locally without a service principal
# use_service_principal = false

create_private_endpoint = true

instance_resource = 2
location          = "northeurope"
zone              = "1"
