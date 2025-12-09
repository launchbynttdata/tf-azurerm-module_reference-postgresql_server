# https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-server-parameters
server_configuration = {
  "backslash_quote" = "on"
  "log_connections" = "on"
}

# uncomment when running locally without a service principal
# use_service_principal = false

zone = "1"

use_service_principal = false

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
