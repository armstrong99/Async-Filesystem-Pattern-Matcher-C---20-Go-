package main

import (
	"fmt"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"runtime"
	"sort"
	"strings"
	"sync"
	"time"
)

// ============================= func : find files recursivel : find_files ===========================
func findFilesMatchingPattern(dir, pattern string) ([]string, error) {
	var matches []string
	path, err := filepath.Abs(dir)

	if err != nil {
		return nil, fmt.Errorf("error occured matching for dir %s", path)
	} else {
		fmt.Printf("🔍 Searching for files in: %v \n", path)
		fmt.Printf("🫤 Pattern to match: %v \n", pattern)
	}

	er := filepath.WalkDir(path, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if !d.IsDir() {
			if strings.Contains(d.Name(), pattern) {
				matches = append(matches, path)
			}
		}

		return nil
	})

	if er != nil {
		return nil, fmt.Errorf("an error walking through dir %s:  %v", path, er)
	}

	return matches, nil
}

func main() {
	start := time.Now()
	root := "."
	pattern := "_x_"
	main_dir_matches := make([]string, 0, 250)
	matchesChan := make(chan []string, 250)
	dirChan := make(chan string, 250)
	numOfWorkers := runtime.NumCPU() * 4
	var wg sync.WaitGroup

	// ========================set up worker pool=============================
	for range numOfWorkers {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for dir := range dirChan {
				matches, err := findFilesMatchingPattern(dir, pattern)
				if err != nil {
					fmt.Printf("error trying to match for path %s", dir)
					return
				}
				matchesChan <- matches
			}
		}()
	}

	// ================= Read directories & process each dir under *root* ==========================
	entries, err := os.ReadDir(root)

	if err != nil {
		log.Fatalf("Error reading root dir: %v", err)
	}

	for _, entry := range entries {
		if entry.IsDir() {
			dirName := filepath.Join(root, entry.Name())
			dirChan <- dirName
		}
	}
	// ======== CLOSE DIR Chan ==========
	close(dirChan)

	go func() {
		wg.Wait()
		close(matchesChan)
	}()

	// also check files for root
	matches, err := findFilesMatchingPattern(root, pattern)
	if err == nil {
		main_dir_matches = append(main_dir_matches, matches...)
	}

	for match := range matchesChan {
		main_dir_matches = append(main_dir_matches, match...)
	}

	sort.Strings(main_dir_matches)
	if len(main_dir_matches) > 0 {
		for _, match := range main_dir_matches {

			fmt.Printf("Matched files for pattern %s: %v\n", pattern, match)
		}
	} else {
		fmt.Printf("╰─ ‼️  NO Match Found \n")
	}

	totalTimeSpent := time.Since(start)

	fmt.Printf("⏰ Total time spent is %v \n", totalTimeSpent)
}
