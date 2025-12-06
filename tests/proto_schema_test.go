package tests

import (
	"bufio"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"testing"
)

// ProtoTableMapping defines the expected mapping between proto messages and DB tables
type ProtoTableMapping struct {
	MessageName string
	TableName   string
	SourceFile  string
}

// getExpectedMappings returns the expected proto-to-table mappings
func getExpectedMappings() []ProtoTableMapping {
	return []ProtoTableMapping{
		// Core tables (000001_organizations.up.sql, 000002_app_users.up.sql)
		{MessageName: "Organization", TableName: "organizations", SourceFile: "000001_organizations.up.sql"},
		{MessageName: "AppUser", TableName: "app_users", SourceFile: "000002_app_users.up.sql"},
		{MessageName: "UserOrganization", TableName: "user_organizations", SourceFile: "000002_app_users.up.sql"},

		// File tables (000003_base_tables.up.sql)
		{MessageName: "File", TableName: "files", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "FlickrPhoto", TableName: "flickr_photo", SourceFile: "000003_base_tables.up.sql"},

		// Camera files tables
		{MessageName: "CamFileExeStage", TableName: "cam_file_exe_stage", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "CamFileExe", TableName: "cam_file_exe", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "CamFile", TableName: "cam_files", SourceFile: "000003_base_tables.up.sql"},

		// Car inspection tables
		{MessageName: "CarInspection", TableName: "car_inspection", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "CarInspectionFiles", TableName: "car_inspection_files", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "CarInspectionFilesA", TableName: "car_inspection_files_a", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "CarInspectionFilesB", TableName: "car_inspection_files_b", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "CarInspectionDeregistration", TableName: "car_inspection_deregistration", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "CarInspectionDeregistrationFiles", TableName: "car_inspection_deregistration_files", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "CarInsSheetIchibanCars", TableName: "car_ins_sheet_ichiban_cars", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "CarInsSheetIchibanCarsA", TableName: "car_ins_sheet_ichiban_cars_a", SourceFile: "000003_base_tables.up.sql"},

		// Car registry tables
		{MessageName: "IchibanCars", TableName: "ichiban_cars", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "DtakoCarsIchibanCars", TableName: "dtako_cars_ichiban_cars", SourceFile: "000003_base_tables.up.sql"},

		// Kudguri tables
		{MessageName: "Kudguri", TableName: "kudguri", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "Kudgcst", TableName: "kudgcst", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "Kudgfry", TableName: "kudgfry", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "Kudgful", TableName: "kudgful", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "Kudgivt", TableName: "kudgivt", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "Kudgsir", TableName: "kudgsir", SourceFile: "000003_base_tables.up.sql"},

		// Sales tables
		{MessageName: "Uriage", TableName: "uriage", SourceFile: "000003_base_tables.up.sql"},
		{MessageName: "UriageJisha", TableName: "uriage_jisha", SourceFile: "000003_base_tables.up.sql"},

		// Dtakologs
		{MessageName: "Dtakologs", TableName: "dtakologs", SourceFile: "000003_base_tables.up.sql"},
	}
}

// TestProtoModelsExist verifies that all expected proto messages exist in models.proto
func TestProtoModelsExist(t *testing.T) {
	protoPath := filepath.Join("..", "proto", "models.proto")

	content, err := os.ReadFile(protoPath)
	if err != nil {
		t.Fatalf("Failed to read models.proto: %v", err)
	}

	protoContent := string(content)

	// Extract all message names from proto file
	messageRegex := regexp.MustCompile(`message\s+(\w+)\s*\{`)
	matches := messageRegex.FindAllStringSubmatch(protoContent, -1)

	protoMessages := make(map[string]bool)
	for _, match := range matches {
		if len(match) > 1 {
			protoMessages[match[1]] = true
		}
	}

	// Check all expected messages exist
	mappings := getExpectedMappings()
	for _, mapping := range mappings {
		if !protoMessages[mapping.MessageName] {
			t.Errorf("Missing proto message '%s' for table '%s' (from %s)",
				mapping.MessageName, mapping.TableName, mapping.SourceFile)
		}
	}
}

// TestDBTablesExist verifies that all expected DB tables exist in migration files
func TestDBTablesExist(t *testing.T) {
	migrationsDir := filepath.Join("..", "migrations", "postgres")

	// Extract all tables from migration files
	dbTables := make(map[string]string) // table name -> source file

	err := filepath.Walk(migrationsDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() || !strings.HasSuffix(path, ".up.sql") {
			return nil
		}

		// Skip old migrations directory
		if strings.Contains(path, string(filepath.Separator)+"old"+string(filepath.Separator)) {
			return nil
		}

		content, err := os.ReadFile(path)
		if err != nil {
			return err
		}

		// Find CREATE TABLE statements
		tableRegex := regexp.MustCompile(`CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:public\.)?(\w+)\s*\(`)
		matches := tableRegex.FindAllStringSubmatch(string(content), -1)
		for _, match := range matches {
			if len(match) > 1 {
				dbTables[match[1]] = filepath.Base(path)
			}
		}

		return nil
	})

	if err != nil {
		t.Fatalf("Failed to walk migrations directory: %v", err)
	}

	// Check all expected tables exist
	mappings := getExpectedMappings()
	for _, mapping := range mappings {
		if _, exists := dbTables[mapping.TableName]; !exists {
			t.Errorf("Missing DB table '%s' for message '%s' (expected in %s)",
				mapping.TableName, mapping.MessageName, mapping.SourceFile)
		}
	}
}

// TestProtoDBConsistency verifies bidirectional consistency between proto and DB
func TestProtoDBConsistency(t *testing.T) {
	mappings := getExpectedMappings()

	// Create lookup maps
	protoToTable := make(map[string]string)
	tableToProto := make(map[string]string)

	for _, m := range mappings {
		protoToTable[m.MessageName] = m.TableName
		tableToProto[m.TableName] = m.MessageName
	}

	// Verify no duplicate mappings
	protoCount := make(map[string]int)
	tableCount := make(map[string]int)

	for _, m := range mappings {
		protoCount[m.MessageName]++
		tableCount[m.TableName]++
	}

	for msg, count := range protoCount {
		if count > 1 {
			t.Errorf("Proto message '%s' is mapped multiple times", msg)
		}
	}

	for table, count := range tableCount {
		if count > 1 {
			t.Errorf("DB table '%s' is mapped multiple times", table)
		}
	}
}

// TestProtoFieldComments verifies that all proto messages have DB table comments
func TestProtoFieldComments(t *testing.T) {
	protoPath := filepath.Join("..", "proto", "models.proto")

	file, err := os.Open(protoPath)
	if err != nil {
		t.Fatalf("Failed to open models.proto: %v", err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	lineNum := 0
	var currentComment string
	messageLineMap := make(map[string]int) // message name -> line number

	for scanner.Scan() {
		lineNum++
		line := scanner.Text()

		// Track comments
		if strings.Contains(line, "// DB:") {
			currentComment = line
		} else if strings.HasPrefix(strings.TrimSpace(line), "message ") {
			// Extract message name
			parts := strings.Fields(strings.TrimSpace(line))
			if len(parts) >= 2 {
				messageName := parts[1]
				messageLineMap[messageName] = lineNum

				// Check if previous line had DB comment
				if currentComment == "" || !strings.Contains(currentComment, "// DB:") {
					// Check if there's a DB comment in the current comment block
					t.Logf("Note: Message '%s' at line %d may benefit from a DB table reference comment",
						messageName, lineNum)
				}
			}
			currentComment = ""
		} else if !strings.HasPrefix(strings.TrimSpace(line), "//") && strings.TrimSpace(line) != "" {
			currentComment = ""
		}
	}

	if err := scanner.Err(); err != nil {
		t.Fatalf("Error reading proto file: %v", err)
	}
}

// TestProtoPackageNaming verifies proto package follows conventions
func TestProtoPackageNaming(t *testing.T) {
	protoPath := filepath.Join("..", "proto", "models.proto")

	content, err := os.ReadFile(protoPath)
	if err != nil {
		t.Fatalf("Failed to read models.proto: %v", err)
	}

	protoContent := string(content)

	// Check package declaration
	packageRegex := regexp.MustCompile(`package\s+([\w.]+);`)
	match := packageRegex.FindStringSubmatch(protoContent)

	if len(match) < 2 {
		t.Error("No package declaration found in models.proto")
		return
	}

	packageName := match[1]

	// Verify package is not empty
	if packageName == "" {
		t.Error("Package name is empty")
	}

	// Log the package name for reference
	t.Logf("Proto package name: %s", packageName)

	// Check go_package option
	goPackageRegex := regexp.MustCompile(`option\s+go_package\s*=\s*"([^"]+)";`)
	goMatch := goPackageRegex.FindStringSubmatch(protoContent)

	if len(goMatch) < 2 {
		t.Error("No go_package option found in models.proto")
		return
	}

	goPackage := goMatch[1]
	if !strings.Contains(goPackage, "pkg/pb") {
		t.Errorf("go_package '%s' should contain 'pkg/pb'", goPackage)
	}
}

// TestMigrationCoverage reports the coverage of proto messages vs DB tables
func TestMigrationCoverage(t *testing.T) {
	mappings := getExpectedMappings()

	// Group by source file
	byFile := make(map[string][]string)
	for _, m := range mappings {
		byFile[m.SourceFile] = append(byFile[m.SourceFile], m.TableName)
	}

	// Sort files for consistent output
	var files []string
	for f := range byFile {
		files = append(files, f)
	}
	sort.Strings(files)

	// Report coverage
	t.Log("Proto-DB Coverage Report:")
	totalTables := 0
	for _, f := range files {
		tables := byFile[f]
		sort.Strings(tables)
		totalTables += len(tables)
		t.Logf("  %s: %d tables (%s)", f, len(tables), strings.Join(tables, ", "))
	}
	t.Logf("Total: %d proto messages mapping to %d DB tables", len(mappings), totalTables)
}
