package testimpl

import (
	"context"
	"os"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/cloud"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	armPostgres "github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/postgresql/armpostgresqlflexibleservers"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
)

func TestPostgresqlServer(t *testing.T, ctx types.TestContext) {
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
	if len(subscriptionId) == 0 {
		t.Fatal("ARM_SUBSCRIPTION_ID environment variable is not set")
	}

	credential, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		t.Fatalf("Unable to get credentials: %e\n", err)
	}

	options := arm.ClientOptions{
		ClientOptions: azcore.ClientOptions{
			Cloud: cloud.AzurePublic,
		},
	}

	armPostgresClient, err := armPostgres.NewServersClient(subscriptionId, credential, &options)
	if err != nil {
		t.Fatalf("Error getting Postgres client: %v", err)
	}

	t.Run("doesPostgresqlServerExist", func(t *testing.T) {
		resourceGroupName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")
		postgresqlName := terraform.Output(t, ctx.TerratestTerraformOptions(), "postgres_name")

		postgresqlServer, err := armPostgresClient.Get(context.Background(), resourceGroupName, postgresqlName, nil)
		if err != nil {
			t.Fatalf("Error getting Postgresql server: %v", err)
		}

		assert.Equal(t, postgresqlName, *postgresqlServer.Name)
	})

	t.Run("postgresqlDiagnosticSettingConfigured", func(t *testing.T) {
		diagnosticSettingID := terraform.Output(t, ctx.TerratestTerraformOptions(), "diagnostic_setting_id")
		diagnosticSettingName := terraform.Output(t, ctx.TerratestTerraformOptions(), "diagnostic_setting_name")
		workspaceID := terraform.Output(t, ctx.TerratestTerraformOptions(), "diagnostic_log_analytics_workspace_id")
		categories := terraform.OutputList(t, ctx.TerratestTerraformOptions(), "diagnostic_log_categories")

		assert.NotEmpty(t, diagnosticSettingID)
		assert.Equal(t, "postgresql-server-diagnostics", diagnosticSettingName)
		assert.NotEmpty(t, workspaceID)
		assert.GreaterOrEqual(t, len(categories), 7)
		assert.Contains(t, categories, "PostgreSQLLogs")
		assert.Contains(t, categories, "PostgreSQLFlexDatabaseXacts")
	})
}
