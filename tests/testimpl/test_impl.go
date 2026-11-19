package testimpl

import (
	"context"
	"os"
	"strings"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/cloud"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/monitor/armmonitor"
	armPostgres "github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/postgresql/armpostgresqlflexibleservers"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// expectedDiagnosticLogCategories is the full PostgreSQL Flexible Server log category set required
// by ticket 12864. It is kept independent of the module defaults so the test fails if they drift.
var expectedDiagnosticLogCategories = []string{
	"PostgreSQLLogs",
	"PostgreSQLFlexSessions",
	"PostgreSQLFlexQueryStoreRuntime",
	"PostgreSQLFlexQueryStoreWaitStats",
	"PostgreSQLFlexTableStats",
	"PostgreSQLFlexDatabaseXacts",
	"PostgreSQLFlexPGBouncer",
	"PostgreSQLQueryStoreSqlText",
}

// TestComposableComplete is the entry point for the functional (post_deploy_functional) suite.
func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	verifyPostgresqlServer(t, ctx)
}

// TestComposableCompleteReadOnly is the entry point for the readonly
// (post_deploy_functional_readonly) suite. lib.RunNonDestructiveTest requires the name of the
// function it runs to start with "TestComposable". It shares verifyPostgresqlServer with the
// functional suite, which is valid only because that function performs reads and assertions and
// never mutates state.
func TestComposableCompleteReadOnly(t *testing.T, ctx types.TestContext) {
	verifyPostgresqlServer(t, ctx)
}

// verifyPostgresqlServer checks the deployed server and its diagnostic setting through the
// Azure APIs. It must stay read-only: both suites call it.
func verifyPostgresqlServer(t *testing.T, ctx types.TestContext) {
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
	if len(subscriptionId) == 0 {
		t.Fatal("ARM_SUBSCRIPTION_ID environment variable is not set")
	}

	credential, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		t.Fatalf("Unable to get credentials: %v\n", err)
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

	// Verifies the diagnostic setting as Azure Monitor reports it, rather than re-reading
	// Terraform outputs (which only mirror the requested inputs).
	t.Run("postgresqlDiagnosticSettingConfigured", func(t *testing.T) {
		diagnosticSettingsClient, err := armmonitor.NewDiagnosticSettingsClient(credential, &options)
		if err != nil {
			t.Fatalf("Error creating diagnostic settings client: %v", err)
		}

		serverID := terraform.Output(t, ctx.TerratestTerraformOptions(), "postgres_id")
		diagnosticSettingName := terraform.Output(t, ctx.TerratestTerraformOptions(), "diagnostic_setting_name")
		expectedWorkspaceID := terraform.Output(t, ctx.TerratestTerraformOptions(), "diagnostic_log_analytics_workspace_id")

		require.NotEmpty(t, serverID)
		require.NotEmpty(t, diagnosticSettingName)
		require.NotEmpty(t, expectedWorkspaceID)

		diagnosticSetting, err := diagnosticSettingsClient.Get(context.Background(), serverID, diagnosticSettingName, nil)
		if err != nil {
			t.Fatalf("Error getting diagnostic setting %q for %s: %v", diagnosticSettingName, serverID, err)
		}

		if diagnosticSetting.Properties == nil {
			t.Fatalf("Diagnostic setting %q returned no properties", diagnosticSettingName)
		}

		if assert.NotNil(t, diagnosticSetting.Name) {
			assert.Equal(t, diagnosticSettingName, *diagnosticSetting.Name)
		}

		// Azure may normalise the casing of resource IDs, so compare case-insensitively.
		if assert.NotNil(t, diagnosticSetting.Properties.WorkspaceID) {
			assert.True(t, strings.EqualFold(expectedWorkspaceID, *diagnosticSetting.Properties.WorkspaceID),
				"workspace ID mismatch: expected %s, got %s", expectedWorkspaceID, *diagnosticSetting.Properties.WorkspaceID)
		}

		enabledCategories := map[string]bool{}
		for _, logSetting := range diagnosticSetting.Properties.Logs {
			if logSetting == nil || logSetting.Category == nil || logSetting.Enabled == nil || !*logSetting.Enabled {
				continue
			}
			enabledCategories[strings.ToLower(*logSetting.Category)] = true
		}

		for _, category := range expectedDiagnosticLogCategories {
			assert.True(t, enabledCategories[strings.ToLower(category)],
				"log category %s is not enabled on diagnostic setting %q", category, diagnosticSettingName)
		}
	})
}
