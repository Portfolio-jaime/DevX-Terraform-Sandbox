package models

import "time"

// SandboxEnvironment represents the state of the sandbox environment
type SandboxEnvironment struct {
	TestArtifactsDir    string
	LocalArtifactsDir   string
	TotalArtifacts      int
	TestArtifactsCount  int
	LocalArtifactsCount int
	DiskUsage           int64 // in bytes
	LastCleanup         time.Time
}

// SandboxStatus represents the overall status of the sandbox
type SandboxStatus struct {
	Environment     SandboxEnvironment
	IsHealthy       bool
	Issues          []string
	Recommendations []string
}
