package main

import (
	"context"
	"log"
	"net"
	"os"

	"github.com/creachadair/jrpc2"
	"github.com/creachadair/jrpc2/channel"
	"github.com/creachadair/jrpc2/handler"
	"github.com/creachadair/jrpc2/server"
	"nvim-features/features/cwd"
)

func build_sock() string {
	if len(os.Args) != 2 {
		return ""
	}

	id := os.Args[1]
	if id == "" {
		return ""
	}

	return "/tmp/nvim-features-" + id + ".sock"
}

func main() {
	sock := build_sock()
	if sock == "" {
		return
	}

	lst, err := net.Listen(jrpc2.Network(sock))
	if err != nil {
		log.Fatalf("Listen %q: %v", sock, err)
	}
	defer lst.Close()

	svc := server.Static(handler.Map{
		"Multiply": handler.New(cwd.Multiply),
	})
	ctx := context.Background()
	server.Loop(ctx, server.NetAccepter(lst, channel.Line), svc, nil)
}
