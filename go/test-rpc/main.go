package main

import (
	"log"
	"os"

	"github.com/neovim/go-client/nvim"
)

func main() {
	// Turn off timestamps in output.
	log.SetFlags(0)

	// Direct writes by the application to stdout garble the RPC stream.
	// Redirect the application's direct use of stdout to stderr.
	stdout := os.Stdout
	os.Stdout = os.Stderr

	// Create a client connected to stdio. Configure the client to use the
	// standard log package for logging.
	v, err := nvim.New(os.Stdin, stdout, stdout, log.Printf)
	if err != nil {
		log.Fatal(err)
	}

	v.RegisterHandler("multiply", Multiply)

	if err := v.Serve(); err != nil {
		log.Fatal(err)
	}
}
