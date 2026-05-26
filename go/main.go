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

func main() {
	if len(os.Args) != 2 {
		return
	}

	sock := os.Args[1]
	if sock == "" {
		return
	}

	os.Remove(sock)

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
