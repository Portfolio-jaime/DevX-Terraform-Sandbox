package cmd

import (
	"github.com/fatih/color"
	"github.com/spf13/cobra"
)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "nx-sandbox",
	Short: color.CyanString("Nx Sandbox - Artifact Testing Environment"),
	Long: color.BlueString(`Nx Sandbox is a CLI tool for managing local testing environments
for Nexus artifacts. It provides functionality to list, clone, and manage
artifacts for development and testing purposes.

Examples:
  nx-sandbox list
  nx-sandbox list --from-inventory
  nx-sandbox status
  nx-sandbox clean
  nx-sandbox clone BritishAirways-Nexus nx-tc-order-creator`),
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() error {
	return rootCmd.Execute()
}

func init() {
	// Initialize all commands
	initListCmd()
	initStatusCmd()
	initCleanCmd()
	initCloneCmd()
}
