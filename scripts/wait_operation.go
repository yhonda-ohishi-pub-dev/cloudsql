package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

func findGcloud() string {
	// Common gcloud paths on Windows
	paths := []string{
		filepath.Join(os.Getenv("LOCALAPPDATA"), "Google", "Cloud SDK", "google-cloud-sdk", "bin", "gcloud.cmd"),
		filepath.Join(os.Getenv("APPDATA"), "Google", "Cloud SDK", "google-cloud-sdk", "bin", "gcloud.cmd"),
		`C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd`,
		`C:\Program Files\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd`,
	}
	for _, p := range paths {
		if _, err := os.Stat(p); err == nil {
			return p
		}
	}
	return "gcloud" // fallback to PATH
}

func main() {
	project := "cloudsql-sv"
	instance := "postgres-test"
	gcloud := findGcloud()

	fmt.Printf("Using gcloud: %s\n", gcloud)
	fmt.Println("Waiting for CloudSQL operation to complete...")

	for {
		cmd := exec.Command(gcloud, "sql", "operations", "list",
			"--instance="+instance,
			"--project="+project,
			"--limit=1",
			"--format=value(status)")

		output, err := cmd.Output()
		if err != nil {
			fmt.Println("Error:", err)
			os.Exit(1)
		}

		status := strings.TrimSpace(string(output))
		fmt.Printf("[%s] Status: %s\n", time.Now().Format("15:04:05"), status)

		if status == "DONE" {
			fmt.Println("Operation completed!")
			break
		}

		time.Sleep(5 * time.Second)
	}
}
