package cwd

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

type Cwd struct {
	Paths               []string
	IncludeHomeGitRepos bool
}

func normalize(path string) (string, error) {
	path, found := strings.CutPrefix(path, "~")
	if found {
		home, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		path = filepath.Join(home, path)
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
	var dirs []string

	entries, err := os.ReadDir(root)
	for _, e := range entries {
		if e.IsDir() {
			dirs = append(dirs, filepath.Join(root, e.Name()))
		}
	}

	if err != nil {
		return nil, err
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
	var (
		dirs []string
		err  error
	)

	for _, p := range config.Paths {
		p, err = normalize(p)
		if err != nil {
			return nil, fmt.Errorf("could not normalize: %v", err)
		}

		dirs, err = firstLevelDirectories(p)
		if err != nil {
			return nil, fmt.Errorf("error getting first level dirs: %v", err)
		}
	}

	var	(
		home string
		homeDirs []string
	)

	if !config.IncludeHomeGitRepos {
		goto pass
	}

	home, err = os.UserHomeDir()
	if err != nil {
		return nil, err
	}
	homeDirs, err = firstLevelDirectories(home)
	for _, d := range(homeDirs) {
		if isGitRepo(d) {
			dirs = append(dirs, d)
		}
	}

pass:
	sort.Strings(dirs)

	return dirs, nil
}
