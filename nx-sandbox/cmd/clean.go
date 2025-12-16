package cmd

import (
	"os"

	"github.com/BritishAirways-Nexus/nx-sandbox/internal/sandbox"
	"github.com/fatih/color"
	"github.com/spf13/cobra"
)

var cleanCmd = &cobra.Command{
	Use:   "clean",
	Short: color.RedString("Clean sandbox artifacts"),
	Long: color.BlueString(`Clean old and temporary artifacts from the sandbox environment.
This removes test artifacts older than 7 days and local artifacts older than 30 days.

Examples:
  nx-sandbox clean`),
	RunE: runCleanCmd,
}

func initCleanCmd() {
	rootCmd.AddCommand(cleanCmd)
}

func runCleanCmd(cmd *cobra.Command, args []string) error {
	color.Yellow("🧹 Starting sandbox cleanup...")

	// Determine base directory
	baseDir := "."
	if wd, err := os.Getwd(); err == nil {
		if baseDirName := getDirName(wd); baseDirName == "nx-sandbox" {
			baseDir = ".."
		}
	}

	// Create sandbox manager
	manager := sandbox.NewSandboxManager(baseDir)

	// Perform cleanup
	if err := manager.Clean(); err != nil {
		color.Red("Error during cleanup: %v", err)
		return err
	}

	color.Green("✅ Sandbox cleanup completed successfully!")

	// Show updated status
	color.Cyan("📊 Updated sandbox status:")
	return runStatusCmd(cmd, []string{})
}
