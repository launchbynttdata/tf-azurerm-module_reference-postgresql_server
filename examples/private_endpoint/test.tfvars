# Known coverage gap: the optional `server_configuration` path has no integration coverage.
# Deleting a server parameter during teardown can race the server destroy and fail with
# ServerIsBusy, so CI keeps this empty. Follow-up: fix the teardown ordering, then restore one
# deterministic parameter here and in examples/complete/test.tfvars.
server_configuration = {}

# uncomment when running locally without a service principal
# use_service_principal = false

create_private_endpoint = true

instance_resource          = 1
location                   = "northeurope"
zone                       = "1"
time_to_wait_after_destroy = "180s"
