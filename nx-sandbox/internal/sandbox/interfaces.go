package sandbox

import (
	"time"

	"github.com/BritishAirways-Nexus/nx-sandbox/internal/models"
)

// ArtifactLister defines the interface for listing artifacts
type ArtifactLister interface {
	ListArtifacts(filter models.ArtifactFilter) ([]models.SandboxArtifact, error)
	GetArtifactInfo(name string) (*models.SandboxArtifact, error)
}

// SandboxManager defines the interface for overall sandbox management
type SandboxManager interface {
	ArtifactLister
	GetStatus() (*models.SandboxStatus, error)
	Clean() error
	CloneArtifact(org, repo string, prepareTesting bool) error
}

// SandboxCleaner defines the interface for cleanup operations
type SandboxCleaner interface {
	CleanTestArtifacts() error
	CleanLocalArtifacts() error
	GetCleanupStatus() (time.Time, error)
}
