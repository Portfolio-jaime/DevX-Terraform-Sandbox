package cmd

import (
	"os"

	"github.com/BritishAirways-Nexus/nx-sandbox/internal/sandbox"
	"github.com/fatih/color"
	"github.com/spf13/cobra"
)

var (
	clonePrepareTesting bool
)

var cloneCmd = &cobra.Command{
	Use:   "clone <organization> <repository>",
	Short: color.MagentaString("Clone artifact from GitHub"),
	Long: color.BlueString(`Clone an artifact repository from GitHub for local testing.
Optionally prepare the artifact for testing by creating necessary files.

Examples:
  nx-sandbox clone BritishAirways-Nexus nx-tc-order-creator
  nx-sandbox clone BritishAirways-Nexus nx-ch-web-checkout --prepare-testing`),
	Args: cobra.ExactArgs(2),
	RunE: runCloneCmd,
}

func initCloneCmd() {
	rootCmd.AddCommand(cloneCmd)

	cloneCmd.Flags().BoolVar(&clonePrepareTesting, "prepare-testing", false, "Prepare artifact for testing after cloning")
}

func runCloneCmd(cmd *cobra.Command, args []string) error {
	org := args[0]
	repo := args[1]

	color.Cyan("🔄 Cloning artifact from GitHub...")
	color.Yellow("Organization: %s", org)
	color.Yellow("Repository: %s", repo)
	color.Yellow("Prepare for testing: %t", clonePrepareTesting)

	// Determine base directory
	baseDir := "."
	if wd, err := os.Getwd(); err == nil {
		if baseDirName := getDirName(wd); baseDirName == "nx-sandbox" {
			baseDir = ".."
		}
	}

	// Create sandbox manager
	manager := sandbox.NewSandboxManager(baseDir)

	// Clone artifact
	if err := manager.CloneArtifact(org, repo, clonePrepareTesting); err != nil {
		color.Red("Error cloning artifact: %v", err)
		return err
	}

	color.Green("✅ Artifact cloned successfully!")

	if clonePrepareTesting {
		color.Cyan("🎯 Artifact prepared for testing")
		color.Cyan("💡 You can now run tests or modify the artifact")
	} else {
		color.Cyan("💡 Use --prepare-testing flag to automatically set up the artifact for testing")
	}

	return nil
}
