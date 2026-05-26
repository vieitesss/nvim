package main

import (
	"context"
	"fmt"
	"strconv"
)

func parseArgs(args []string) (int, int, error) {
	if len(args) != 2 {
		return 0, 0, fmt.Errorf("expected exactly two integers, got %d.", len(args))
	}

	a, err := strconv.Atoi(args[0])
	if err != nil {
		return 0, 0, err
	}

	b, err := strconv.Atoi(args[1])
	if err != nil {
		return 0, 0, err
	}

	return a, b, nil
}

func Multiply(ctx context.Context, args []string) (int, error) {
	a, b, err := parseArgs(args)
	if err != nil {
		return 0, err
	}
	m := a * b

	return m, nil
}
