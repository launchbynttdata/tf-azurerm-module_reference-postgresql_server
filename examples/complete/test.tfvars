# Known coverage gap: the optional `server_configuration` path has no integration coverage.
# Deleting a server parameter during teardown can race the server destroy and fail with
# ServerIsBusy, so CI keeps this empty. Follow-up: fix the teardown ordering, then restore one
# deterministic parameter here and in examples/private_endpoint/test.tfvars.
server_configuration = {}

instance_resource          = 1
location                   = "northeurope"
zone                       = "1"
time_to_wait_after_destroy = "120s"

action_group = {
  name       = "test-action"
  short_name = "Test"
}
# Two sample metric alerts for testing
metric_alerts = {
  "test_cpu_percent" = {
    description = "CPU usage over 70% (test alert)"
    frequency   = "PT1M"
    severity    = 3
    enabled     = true
    criteria = [
      {
        metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
        metric_name      = "cpu_percent"
        aggregation      = "Average"
        operator         = "GreaterThan"
        threshold        = 70
      }
    ]
  }

  "test_active_connections" = {
    description = "Active connections > 100 (test alert)"
    frequency   = "PT1M"
    severity    = 3
    enabled     = true
    criteria = [
      {
        metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
        metric_name      = "active_connections"
        aggregation      = "Average"
        operator         = "GreaterThan"
        threshold        = 100
      }
    ]
  }
}
