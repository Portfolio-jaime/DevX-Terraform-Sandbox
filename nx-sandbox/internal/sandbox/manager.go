package sandbox

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/BritishAirways-Nexus/nx-sandbox/internal/models"
)

// DefaultSandboxManager implements the SandboxManager interface
type DefaultSandboxManager struct {
	baseDir string
}

// NewSandboxManager creates a new sandbox manager
func NewSandboxManager(baseDir string) SandboxManager {
	return &DefaultSandboxManager{
		baseDir: baseDir,
	}
}

// ListArtifacts implements ArtifactLister interface
func (m *DefaultSandboxManager) ListArtifacts(filter models.ArtifactFilter) ([]models.SandboxArtifact, error) {
	var artifacts []models.SandboxArtifact

	// Scan inventory artifacts
	if filter.Source == "" || filter.Source == models.SourceInventory {
		inventoryArtifacts, err := m.scanInventoryArtifacts(filter)
		if err != nil {
			return nil, fmt.Errorf("failed to scan inventory artifacts: %w", err)
		}
		artifacts = append(artifacts, inventoryArtifacts...)
	}

	// Scan environment artifacts
	if filter.Source == "" || filter.Source == models.SourceEnvironment {
		envArtifacts, err := m.scanEnvironmentArtifacts(filter)
		if err != nil {
			return nil, fmt.Errorf("failed to scan environment artifacts: %w", err)
		}
		artifacts = append(artifacts, envArtifacts...)
	}

	return artifacts, nil
}

// GetArtifactInfo implements ArtifactLister interface
func (m *DefaultSandboxManager) GetArtifactInfo(name string) (*models.SandboxArtifact, error) {
	artifacts, err := m.ListArtifacts(models.ArtifactFilter{})
	if err != nil {
		return nil, err
	}

	for _, artifact := range artifacts {
		if artifact.Name == name {
			return &artifact, nil
		}
	}

	return nil, fmt.Errorf("artifact '%s' not found", name)
}

// GetStatus implements SandboxManager interface
func (m *DefaultSandboxManager) GetStatus() (*models.SandboxStatus, error) {
	env := models.SandboxEnvironment{
		TestArtifactsDir:  filepath.Join(m.baseDir, "test-artifacts"),
		LocalArtifactsDir: filepath.Join(m.baseDir, "local-artifacts"),
	}

	// Count artifacts
	testCount, err := m.countArtifacts(env.TestArtifactsDir)
	if err != nil {
		return nil, fmt.Errorf("failed to count test artifacts: %w", err)
	}
	env.TestArtifactsCount = testCount

	localCount, err := m.countArtifacts(env.LocalArtifactsDir)
	if err != nil {
		return nil, fmt.Errorf("failed to count local artifacts: %w", err)
	}
	env.LocalArtifactsCount = localCount

	env.TotalArtifacts = testCount + localCount

	// Calculate disk usage
	testUsage, err := m.calculateDiskUsage(env.TestArtifactsDir)
	if err != nil {
		return nil, fmt.Errorf("failed to calculate test artifacts disk usage: %w", err)
	}

	localUsage, err := m.calculateDiskUsage(env.LocalArtifactsDir)
	if err != nil {
		return nil, fmt.Errorf("failed to calculate local artifacts disk usage: %w", err)
	}

	env.DiskUsage = testUsage + localUsage

	// Get last cleanup time
	lastCleanup, err := m.getLastCleanupTime()
	if err == nil {
		env.LastCleanup = lastCleanup
	}

	status := &models.SandboxStatus{
		Environment: env,
		IsHealthy:   true,
		Issues:      []string{},
	}

	// Check for issues
	if env.DiskUsage > 1024*1024*1024 { // > 1GB
		status.Issues = append(status.Issues, "High disk usage detected")
		status.IsHealthy = false
	}

	if env.TestArtifactsCount > 50 {
		status.Issues = append(status.Issues, "Many test artifacts - consider cleanup")
	}

	if len(status.Issues) == 0 {
		status.Recommendations = append(status.Recommendations, "Sandbox is in good condition")
	} else {
		status.Recommendations = append(status.Recommendations, "Run 'nx-sandbox clean' to optimize space")
	}

	return status, nil
}

// Clean implements SandboxManager interface
func (m *DefaultSandboxManager) Clean() error {
	testDir := filepath.Join(m.baseDir, "test-artifacts")
	localDir := filepath.Join(m.baseDir, "local-artifacts")

	// Clean test artifacts older than 7 days
	if err := m.cleanOldArtifacts(testDir, 7*24*time.Hour); err != nil {
		return fmt.Errorf("failed to clean test artifacts: %w", err)
	}

	// Clean local artifacts older than 30 days
	if err := m.cleanOldArtifacts(localDir, 30*24*time.Hour); err != nil {
		return fmt.Errorf("failed to clean local artifacts: %w", err)
	}

	// Update cleanup timestamp
	return m.updateLastCleanupTime()
}

// CloneArtifact implements SandboxManager interface
func (m *DefaultSandboxManager) CloneArtifact(org, repo string, prepareTesting bool) error {
	// TODO: Implement GitHub cloning logic
	return fmt.Errorf("CloneArtifact not implemented yet")
}

// Helper methods

func (m *DefaultSandboxManager) scanInventoryArtifacts(filter models.ArtifactFilter) ([]models.SandboxArtifact, error) {
	var artifacts []models.SandboxArtifact

	inventoryDir := filepath.Join(m.baseDir, "repos", "nx-artifacts-inventory", "nx-artifacts")

	layers := []string{"al", "bal", "bb", "bc", "bff", "ch", "tc", "xp"}

	for _, layer := range layers {
		if filter.Layer != "" && filter.Layer != layer {
			continue
		}

		layerDir := filepath.Join(inventoryDir, layer)
		if _, err := os.Stat(layerDir); os.IsNotExist(err) {
			continue
		}

		entries, err := os.ReadDir(layerDir)
		if err != nil {
			continue
		}

		for _, entry := range entries {
			if !entry.IsDir() {
				continue
			}

			artifactName := entry.Name()
			artifactPath := filepath.Join(layerDir, artifactName)

			// Check if it has inventory file
			inventoryPath := filepath.Join(artifactPath, "nx-app-inventory.yaml")
			hasInventory := false
			if _, err := os.Stat(inventoryPath); err == nil {
				hasInventory = true
			}

			// Check if it has Helm chart
			chartPath := filepath.Join(artifactPath, "Chart.yaml")
			hasChart := false
			if _, err := os.Stat(chartPath); err == nil {
				hasChart = true
			}

			artifact := models.SandboxArtifact{
				Name:         artifactName,
				Layer:        layer,
				Path:         artifactPath,
				Source:       models.SourceInventory,
				HasChart:     hasChart,
				HasInventory: hasInventory,
			}

			artifacts = append(artifacts, artifact)
		}
	}

	return artifacts, nil
}

func (m *DefaultSandboxManager) scanEnvironmentArtifacts(filter models.ArtifactFilter) ([]models.SandboxArtifact, error) {
	var artifacts []models.SandboxArtifact

	envPattern := filepath.Join(m.baseDir, "repos", "nx-bolt-environment-*")

	matches, err := filepath.Glob(envPattern)
	if err != nil {
		return nil, err
	}

	for _, envDir := range matches {
		envName := filepath.Base(envDir)
		if strings.HasPrefix(envName, "nx-bolt-environment-") {
			envName = strings.TrimPrefix(envName, "nx-bolt-environment-")
		}

		if filter.Environment != "" && filter.Environment != envName {
			continue
		}

		// Scan layers in environment
		entries, err := os.ReadDir(envDir)
		if err != nil {
			continue
		}

		for _, entry := range entries {
			if !entry.IsDir() {
				continue
			}

			layer := entry.Name()
			if filter.Layer != "" && filter.Layer != layer {
				continue
			}

			layerDir := filepath.Join(envDir, entry.Name())

			// Scan services in layer
			serviceEntries, err := os.ReadDir(layerDir)
			if err != nil {
				continue
			}

			for _, serviceEntry := range serviceEntries {
				if !serviceEntry.IsDir() {
					continue
				}

				serviceName := serviceEntry.Name()
				servicePath := filepath.Join(layerDir, serviceName)

				// Check if it has Helm chart
				chartPath := filepath.Join(servicePath, "Chart.yaml")
				hasChart := false
				if _, err := os.Stat(chartPath); err == nil {
					hasChart = true
				}

				artifact := models.SandboxArtifact{
					Name:        serviceName,
					Layer:       layer,
					Path:        servicePath,
					Source:      models.SourceEnvironment,
					Environment: envName,
					HasChart:    hasChart,
				}

				artifacts = append(artifacts, artifact)
			}
		}
	}

	return artifacts, nil
}

func (m *DefaultSandboxManager) countArtifacts(dir string) (int, error) {
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		return 0, nil
	}

	count := 0
	err := filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() && path != dir {
			count++
		}
		return nil
	})

	return count, err
}

func (m *DefaultSandboxManager) calculateDiskUsage(dir string) (int64, error) {
	var size int64

	if _, err := os.Stat(dir); os.IsNotExist(err) {
		return 0, nil
	}

	err := filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() {
			size += info.Size()
		}
		return nil
	})

	return size, err
}

func (m *DefaultSandboxManager) cleanOldArtifacts(dir string, maxAge time.Duration) error {
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		return nil
	}

	return filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() && path != dir {
			// Check if directory is older than maxAge
			if time.Since(info.ModTime()) > maxAge {
				fmt.Printf("Removing old artifact: %s\n", path)
				return os.RemoveAll(path)
			}
		}

		return nil
	})
}

func (m *DefaultSandboxManager) getLastCleanupTime() (time.Time, error) {
	cleanupFile := filepath.Join(m.baseDir, ".nx-sandbox-cleanup")

	data, err := os.ReadFile(cleanupFile)
	if err != nil {
		return time.Time{}, err
	}

	return time.Parse(time.RFC3339, string(data))
}

func (m *DefaultSandboxManager) updateLastCleanupTime() error {
	cleanupFile := filepath.Join(m.baseDir, ".nx-sandbox-cleanup")
	return os.WriteFile(cleanupFile, []byte(time.Now().Format(time.RFC3339)), 0644)
}
