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
)

const serviceAddr = "/tmp/test-rpc.sock"

func main() {
	os.Remove(serviceAddr)

	lst, err := net.Listen(jrpc2.Network(serviceAddr))
	if err != nil {
		log.Fatalf("Listen %q: %v", serviceAddr, err)
	}
	defer lst.Close()

	svc := server.Static(handler.Map{
		"Multiply": handler.New(Multiply),
	})
	ctx := context.Background()
	server.Loop(ctx, server.NetAccepter(lst, channel.Line), svc, nil)
}
