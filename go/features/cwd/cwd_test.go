package cwd

import (
	"context"
	"os"
	"path/filepath"
	"reflect"
	"testing"
)

// Dummy directory tree:
// root/
//	alpha/
//	  nested/
//	beta/
//	gamma/
//	  deeper/
//	    leaf/
//	not-git/
//	repo/
//	  .git/
//	worktree/
//	  .git
//	file.txt
func mockStructure(t *testing.T) string {
	root := t.TempDir()

	for _, dir := range []string{
		"alpha/nested",
		"beta",
		"gamma/deeper/leaf",
		"not-git",
		"repo/.git",
		"worktree",
	} {
		if err := os.MkdirAll(filepath.Join(root, dir), 0o755); err != nil {
			t.Fatalf("failed to create test directory %q: %v", dir, err)
		}
	}

	if err := os.WriteFile(filepath.Join(root, "worktree", ".git"), []byte("gitdir: ../repo/.git/worktrees/worktree"), 0o644); err != nil {
		t.Fatalf("failed to create git worktree file: %v", err)
	}

	if err := os.WriteFile(filepath.Join(root, "file.txt"), []byte("not a directory"), 0o644); err != nil {
		t.Fatalf("failed to create test file: %v", err)
	}

	t.Setenv("HOME", root)

	return root
}

func removeStructure(t *testing.T, root string) {
	err := os.RemoveAll(root)
	if err != nil {
		t.Fatalf("failed to remove the %s directory: %v", root, err)
	}
}

func TestNormalize(t *testing.T) {
	root := mockStructure(t)

	got, err := normalize(root)
	want := os.Getenv("HOME")
	if got != want {
		t.Fatalf("could not normalize %s: %v", root, err)
	}

	got, err = normalize("~")
	if got != want {
		t.Fatalf("could not normalize ~: %v", err)
	}

	got, err = normalize("~/")
	if got != want {
		t.Fatalf("could not normalize ~/: %v", err)
	}

	got, err = normalize("~/alpha")
	want = os.Getenv("HOME") + "/alpha"
	if got != want {
		t.Fatalf("could not normalize ~/alpha: %v", err)
	}

	removeStructure(t, root)
}

func TestFirstLevelDirectories(t *testing.T) {
	root := mockStructure(t)
	got, err := firstLevelDirectories(root)
	if err != nil {
		t.Fatalf("firstLevelDirectories returned error: %v", err)
	}

	want := []string{
		filepath.Join(root, "alpha"),
		filepath.Join(root, "beta"),
		filepath.Join(root, "gamma"),
		filepath.Join(root, "not-git"),
		filepath.Join(root, "repo"),
		filepath.Join(root, "worktree"),
	}

	if !reflect.DeepEqual(got, want) {
		t.Fatalf("firstLevelDirectories(root) = %#v, want %#v", got, want)
	}

	norm, _ := normalize("~/alpha")
	got, err = firstLevelDirectories(norm)

	want = []string{
		filepath.Join(root, "alpha/nested"),
	}

	if !reflect.DeepEqual(got, want) {
		t.Fatalf("firstLevelDirectories(~/alpha) = %#v, want %#v", got, want)
	}

	removeStructure(t, root)
}

func TestListWithoutGitRepos(t *testing.T) {
	root := mockStructure(t)

	config := Cwd{
		Paths:               []string{root},
		IncludeHomeGitRepos: false,
	}

	got, err := List(context.Background(), config)
	if err != nil {
		t.Fatalf("List returned error: %v", err)
	}

	want := []string{
		filepath.Join(root, "alpha"),
		filepath.Join(root, "beta"),
		filepath.Join(root, "gamma"),
		filepath.Join(root, "not-git"),
		filepath.Join(root, "repo"),
		filepath.Join(root, "worktree"),
	}

	if !reflect.DeepEqual(got, want) {
		t.Fatalf("firstLevelDirectories() = %#v, want %#v", got, want)
	}

	removeStructure(t, root)
}

func TestAnotherListWithoutGitRepos(t *testing.T) {
	root := mockStructure(t)

	config := Cwd{
		Paths:               []string{"~/alpha", "~/beta"},
		IncludeHomeGitRepos: false,
	}

	got, err := List(context.Background(), config)
	if err != nil {
		t.Fatalf("List returned error: %v", err)
	}

	want := []string{
		filepath.Join(root, "alpha/nested"),
	}

	if !reflect.DeepEqual(got, want) {
		t.Fatalf("firstLevelDirectories() = %#v, want %#v", got, want)
	}

	removeStructure(t, root)
}

func TestListWithHomeGitRepos(t *testing.T) {
	root := mockStructure(t)

	config := Cwd{
		Paths:               []string{root},
		IncludeHomeGitRepos: true,
	}

	got, err := List(context.Background(), config)
	if err != nil {
		t.Fatalf("List returned error: %v", err)
	}

	want := []string{
		filepath.Join(root, "alpha"),
		filepath.Join(root, "beta"),
		filepath.Join(root, "gamma"),
		filepath.Join(root, "not-git"),
		filepath.Join(root, "repo"),
		filepath.Join(root, "worktree"),
	}

	if !reflect.DeepEqual(got, want) {
		t.Fatalf("List() = %#v, want %#v", got, want)
	}

	removeStructure(t, root)
}

func TestIsGitRepoAcceptsGitDirectoryAndWorktreeFile(t *testing.T) {
	home := mockStructure(t)

	tests := []struct {
		name string
		path string
		want bool
	}{
		{name: "repository with .git directory", path: filepath.Join(home, "repo"), want: true},
		{name: "worktree with .git file", path: filepath.Join(home, "worktree"), want: true},
		{name: "directory without .git", path: filepath.Join(home, "not-git"), want: false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := isGitRepo(tt.path)
			if got != tt.want {
				t.Fatalf("isGitRepo(%q) = %v, want %v", tt.path, got, tt.want)
			}
		})
	}

	removeStructure(t, home)
}
