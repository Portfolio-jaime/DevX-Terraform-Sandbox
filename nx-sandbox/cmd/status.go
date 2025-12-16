package cmd

import (
	"fmt"
	"os"

	"github.com/BritishAirways-Nexus/nx-sandbox/internal/sandbox"
	"github.com/fatih/color"
	"github.com/spf13/cobra"
)

var statusCmd = &cobra.Command{
	Use:   "status",
	Short: color.GreenString("Show sandbox status"),
	Long: color.BlueString(`Display the current status of the sandbox environment,
including disk usage, artifact counts, and health indicators.

Examples:
  nx-sandbox status`),
	RunE: runStatusCmd,
}

func initStatusCmd() {
	rootCmd.AddCommand(statusCmd)
}

func runStatusCmd(cmd *cobra.Command, args []string) error {
	color.Cyan("🏥 Checking sandbox status...")

	// Determine base directory
	baseDir := "."
	if wd, err := os.Getwd(); err == nil {
		if baseDirName := getDirName(wd); baseDirName == "nx-sandbox" {
			baseDir = ".."
		}
	}

	// Create sandbox manager
	manager := sandbox.NewSandboxManager(baseDir)

	// Get status
	status, err := manager.GetStatus()
	if err != nil {
		color.Red("Error getting sandbox status: %v", err)
		return err
	}

	// Display status
	fmt.Println()
	color.Cyan("📊 Sandbox Status Report")
	fmt.Println("========================")

	// Health status
	if status.IsHealthy {
		color.Green("✅ Overall Status: Healthy")
	} else {
		color.Red("❌ Overall Status: Issues Detected")
	}
	fmt.Println()

	// Environment info
	color.Yellow("📁 Environment:")
	fmt.Printf("   Test Artifacts Directory: %s\n", status.Environment.TestArtifactsDir)
	fmt.Printf("   Local Artifacts Directory: %s\n", status.Environment.LocalArtifactsDir)
	fmt.Printf("   Total Artifacts: %d\n", status.Environment.TotalArtifacts)
	fmt.Printf("   Test Artifacts: %d\n", status.Environment.TestArtifactsCount)
	fmt.Printf("   Local Artifacts: %d\n", status.Environment.LocalArtifactsCount)

	// Disk usage
	diskUsageMB := float64(status.Environment.DiskUsage) / (1024 * 1024)
	if diskUsageMB < 1 {
		fmt.Printf("   Disk Usage: %.2f KB\n", float64(status.Environment.DiskUsage)/1024)
	} else {
		fmt.Printf("   Disk Usage: %.2f MB\n", diskUsageMB)
	}

	// Last cleanup
	if !status.Environment.LastCleanup.IsZero() {
		fmt.Printf("   Last Cleanup: %s\n", status.Environment.LastCleanup.Format("2006-01-02 15:04:05"))
	} else {
		fmt.Printf("   Last Cleanup: Never\n")
	}
	fmt.Println()

	// Issues
	if len(status.Issues) > 0 {
		color.Red("⚠️  Issues:")
		for _, issue := range status.Issues {
			fmt.Printf("   - %s\n", issue)
		}
		fmt.Println()
	}

	// Recommendations
	if len(status.Recommendations) > 0 {
		color.Green("💡 Recommendations:")
		for _, rec := range status.Recommendations {
			fmt.Printf("   - %s\n", rec)
		}
		fmt.Println()
	}

	// Commands
	color.Cyan("🔧 Available Commands:")
	fmt.Println("   nx-sandbox list          # List available artifacts")
	fmt.Println("   nx-sandbox clean         # Clean old artifacts")
	fmt.Println("   nx-sandbox clone <org> <repo>  # Clone artifact for testing")

	return nil
}
