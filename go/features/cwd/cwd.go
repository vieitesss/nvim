package cwd

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

type Cwd struct {
	Paths               []string `json:"paths"`
	IncludeHomeGitRepos bool     `json:"include_home_git_repos"`
}

func normalize(path string) (string, error) {
	if strings.HasPrefix(path, "~") {
		home, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		path = strings.Replace(path, "~", home, 1)
	}

	abs, err := filepath.Abs(path)
	if err != nil {
		return "", err
	}

	if abs != "/" {
		abs, _ = strings.CutSuffix(abs, "/")
	}

	_, err = os.Stat(abs)
	if err != nil {
		return "", err
	}

	return abs, nil
}

func firstLevelDirectories(root string) ([]string, error) {
	entries, err := os.ReadDir(root)
	if err != nil {
		return nil, err
	}

	dirs := make([]string, 0, len(entries))
	for _, e := range entries {
		if e.IsDir() {
			dirs = append(dirs, filepath.Join(root, e.Name()))
		}
	}

	return dirs, nil
}

func isGitRepo(path string) bool {
	_, err := os.Stat(filepath.Join(path, ".git"))
	if err != nil {
		return false
	}

	return true
}

func List(ctx context.Context, config Cwd) ([]string, error) {
	dirs := make([]string, 0)

	for _, p := range config.Paths {
		normalized, err := normalize(p)
		if err != nil {
			log.Printf("skipping configured path %q (normalize): %v", p, err)
			continue
		}
		p = normalized

		fld, err := firstLevelDirectories(p)
		if err != nil {
			log.Printf("skipping configured path %q (readdir): %v", p, err)
			continue
		}

		for _, d := range fld {
			dirs = append(dirs, d)
		}
	}

	if config.IncludeHomeGitRepos {
		home, err := os.UserHomeDir()
		if err != nil {
			return nil, err
		}
		homeDirs, err := firstLevelDirectories(home)
		if err != nil {
			return nil, fmt.Errorf("error getting home dirs: %v", err)
		}
		for _, d := range homeDirs {
			if isGitRepo(d) {
				dirs = append(dirs, d)
			}
		}
	}

	sort.Strings(dirs)

	uniq := dirs[:0]
	for i, d := range dirs {
		if i == 0 || dirs[i-1] != d {
			uniq = append(uniq, d)
		}
	}

	return uniq, nil
}
