# Minimal server_configuration for CI: parameter deletes often return ServerIsBusy during destroy.
server_configuration = {}

# uncomment when running locally without a service principal
# use_service_principal = false

create_private_endpoint = true

instance_resource          = 3
location                   = "northeurope"
zone                       = "1"
time_to_wait_after_destroy = "180s"
