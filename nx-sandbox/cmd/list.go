package cmd

import (
	"fmt"
	"os"
	"path/filepath"
	"text/tabwriter"

	"github.com/BritishAirways-Nexus/nx-sandbox/internal/models"
	"github.com/BritishAirways-Nexus/nx-sandbox/internal/sandbox"
	"github.com/fatih/color"
	"github.com/spf13/cobra"
)

var (
	listFromInventory    bool
	listFromEnvironments bool
	listLayer            string
	listEnvironment      string
)

var listCmd = &cobra.Command{
	Use:   "list",
	Short: color.YellowString("List available artifacts"),
	Long: color.BlueString(`List all available artifacts in the sandbox environment.
You can filter by source (inventory/environments) or by specific layer/environment.

Examples:
  nx-sandbox list
  nx-sandbox list --from-inventory
  nx-sandbox list --from-environments
  nx-sandbox list --layer bff
  nx-sandbox list --environment dev1`),
	RunE: runListCmd,
}

func initListCmd() {
	rootCmd.AddCommand(listCmd)

	listCmd.Flags().BoolVar(&listFromInventory, "from-inventory", false, "List only artifacts from inventory")
	listCmd.Flags().BoolVar(&listFromEnvironments, "from-environments", false, "List only artifacts from environments")
	listCmd.Flags().StringVar(&listLayer, "layer", "", "Filter by specific layer (al, bal, bb, bc, bff, ch, tc, xp)")
	listCmd.Flags().StringVar(&listEnvironment, "environment", "", "Filter by specific environment")
}

func runListCmd(cmd *cobra.Command, args []string) error {
	color.Cyan("🔍 Scanning artifacts...")

	// Determine base directory (parent of nx-sandbox directory)
	baseDir := "."
	if wd, err := os.Getwd(); err == nil {
		// If we're in nx-sandbox directory, go up one level
		if baseDirName := getDirName(wd); baseDirName == "nx-sandbox" {
			baseDir = ".."
		}
	}

	// Create sandbox manager
	manager := sandbox.NewSandboxManager(baseDir)

	// Build filter
	filter := models.ArtifactFilter{
		Layer:       listLayer,
		Environment: listEnvironment,
	}

	if listFromInventory {
		filter.Source = models.SourceInventory
	} else if listFromEnvironments {
		filter.Source = models.SourceEnvironment
	}

	// List artifacts
	artifacts, err := manager.ListArtifacts(filter)
	if err != nil {
		color.Red("Error listing artifacts: %v", err)
		return err
	}

	if len(artifacts) == 0 {
		color.Yellow("No artifacts found matching the criteria.")
		return nil
	}

	color.Green("Found %d artifact(s):", len(artifacts))
	fmt.Println()

	// Display results in a table
	w := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
	fmt.Fprintln(w, "NAME\tLAYER\tSOURCE\tENVIRONMENT\tCHART\tINVENTORY")
	fmt.Fprintln(w, "----\t-----\t------\t-----------\t-----\t---------")

	for _, artifact := range artifacts {
		chartStatus := "❌"
		if artifact.HasChart {
			chartStatus = "✅"
		}

		inventoryStatus := "❌"
		if artifact.HasInventory {
			inventoryStatus = "✅"
		}

		env := artifact.Environment
		if env == "" {
			env = "-"
		}

		fmt.Fprintf(w, "%s\t%s\t%s\t%s\t%s\t%s\n",
			artifact.Name,
			artifact.Layer,
			string(artifact.Source),
			env,
			chartStatus,
			inventoryStatus)
	}

	w.Flush()
	fmt.Println()

	color.Cyan("💡 Use 'nx-sandbox clone <org> <repo>' to clone artifacts for testing")
	color.Cyan("💡 Use 'nx-sandbox status' to check sandbox health")

	return nil
}

func getDirName(path string) string {
	return filepath.Base(path)
}
