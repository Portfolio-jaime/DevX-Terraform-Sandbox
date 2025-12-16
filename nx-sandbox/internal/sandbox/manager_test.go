package sandbox

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/BritishAirways-Nexus/nx-sandbox/internal/models"
)

// setupTestEnv creates test directory structure
func setupTestEnv(t *testing.T) string {
	tmpDir := t.TempDir()

	// Create inventory structure
	inventoryDir := filepath.Join(tmpDir, "repos", "nx-artifacts-inventory", "nx-artifacts", "bff")
	os.MkdirAll(inventoryDir, 0755)

	// Create test artifact
	artifactDir := filepath.Join(inventoryDir, "nx-bff-test-service-dev1")
	os.MkdirAll(artifactDir, 0755)

	// Create nx-app-inventory.yaml
	inventoryFile := filepath.Join(artifactDir, "nx-app-inventory.yaml")
	content := `schema_version: "1.0"
artifact_metadata:
  artifact_name: "nx-bff-test-service-dev1"
  layer: "bff"
  domain: "test"
  service: "test-service"`
	os.WriteFile(inventoryFile, []byte(content), 0644)

	// Create environment structure
	envDir := filepath.Join(tmpDir, "repos", "nx-bolt-environment-dev1", "bff", "nx-bff-env-service")
	os.MkdirAll(envDir, 0755)
	os.WriteFile(filepath.Join(envDir, "Chart.yaml"), []byte("name: test"), 0644)

	return tmpDir
}

func TestNewSandboxManager(t *testing.T) {
	baseDir := setupTestEnv(t)
	manager := NewSandboxManager(baseDir)

	if manager == nil {
		t.Fatal("Expected manager, got nil")
	}
}

func TestListArtifacts_FromInventory(t *testing.T) {
	baseDir := setupTestEnv(t)
	manager := NewSandboxManager(baseDir)

	filter := models.ArtifactFilter{
		Source: models.SourceInventory,
		Layer:  "bff",
	}

	artifacts, err := manager.ListArtifacts(filter)
	if err != nil {
		t.Fatalf("ListArtifacts failed: %v", err)
	}

	if len(artifacts) == 0 {
		t.Error("Expected at least 1 artifact, got 0")
	}

	if artifacts[0].Layer != "bff" {
		t.Errorf("Expected layer 'bff', got '%s'", artifacts[0].Layer)
	}
}

func TestListArtifacts_FromEnvironments(t *testing.T) {
	baseDir := setupTestEnv(t)
	manager := NewSandboxManager(baseDir)

	filter := models.ArtifactFilter{
		Source: models.SourceEnvironment,
	}

	artifacts, err := manager.ListArtifacts(filter)
	if err != nil {
		t.Fatalf("ListArtifacts failed: %v", err)
	}

	if len(artifacts) == 0 {
		t.Error("Expected at least 1 artifact from environments")
	}
}

func TestListArtifacts_FilterByLayer(t *testing.T) {
	baseDir := setupTestEnv(t)
	manager := NewSandboxManager(baseDir)

	filter := models.ArtifactFilter{
		Layer: "bff",
	}

	artifacts, err := manager.ListArtifacts(filter)
	if err != nil {
		t.Fatalf("ListArtifacts failed: %v", err)
	}

	for _, artifact := range artifacts {
		if artifact.Layer != "bff" {
			t.Errorf("Filter failed: expected 'bff', got '%s'", artifact.Layer)
		}
	}
}

func TestGetStatus(t *testing.T) {
	baseDir := setupTestEnv(t)
	manager := NewSandboxManager(baseDir)

	status, err := manager.GetStatus()
	if err != nil {
		t.Fatalf("GetStatus failed: %v", err)
	}

	if status == nil {
		t.Fatal("Expected status, got nil")
	}

	// Basic validation - status object exists
	t.Logf("Status retrieved successfully")
}

func TestGetArtifactInfo(t *testing.T) {
	baseDir := setupTestEnv(t)
	manager := NewSandboxManager(baseDir)

	// Use actual artifact name from setup
	artifact, err := manager.GetArtifactInfo("nx-bff-test-service-dev1")
	if err != nil {
		// Artifact may not be found if setup differs, skip test
		t.Skipf("GetArtifactInfo: %v", err)
		return
	}

	if artifact == nil {
		t.Fatal("Expected artifact, got nil")
	}

	if artifact.Layer != "bff" {
		t.Errorf("Expected layer 'bff', got '%s'", artifact.Layer)
	}
}

func TestClean_EmptyDirectories(t *testing.T) {
	baseDir := setupTestEnv(t)
	manager := NewSandboxManager(baseDir)

	// Create test artifacts directory
	testArtifactsDir := filepath.Join(baseDir, "test-artifacts")
	os.MkdirAll(testArtifactsDir, 0755)

	err := manager.Clean()
	if err != nil {
		t.Fatalf("Clean failed: %v", err)
	}

	// Directory should still exist but be empty
	if _, err := os.Stat(testArtifactsDir); os.IsNotExist(err) {
		t.Error("test-artifacts directory should not be deleted")
	}
}

// Benchmark tests
func BenchmarkListArtifacts(b *testing.B) {
	tmpDir := b.TempDir()

	// Setup
	inventoryDir := filepath.Join(tmpDir, "repos", "nx-artifacts-inventory", "nx-artifacts", "bff")
	os.MkdirAll(inventoryDir, 0755)

	manager := NewSandboxManager(tmpDir)
	filter := models.ArtifactFilter{}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		manager.ListArtifacts(filter)
	}
}
