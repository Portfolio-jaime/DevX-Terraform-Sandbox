package models

import "time"

// ArtifactSource represents the source of an artifact
type ArtifactSource string

const (
	SourceInventory   ArtifactSource = "inventory"
	SourceEnvironment ArtifactSource = "environment"
)

// SandboxArtifact represents an artifact available for testing
type SandboxArtifact struct {
	Name         string
	Layer        string
	Path         string
	Source       ArtifactSource
	Environment  string
	HasChart     bool
	HasInventory bool
	LastModified time.Time
}

// ArtifactFilter represents filtering options for artifact listing
type ArtifactFilter struct {
	Source      ArtifactSource
	Layer       string
	Environment string
}
