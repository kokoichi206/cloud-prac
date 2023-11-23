package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"time"

	pb "github.com/kokoichi206/cloud-prac/kube/kind/protobuf/gen/go/protobuf"
	"google.golang.org/grpc"
)

type handler struct {
	pb.UnimplementedSampleServer
}

func (h *handler) Health(ctx context.Context, in *pb.HealthRequest) (*pb.HealthReply, error) {
	log.Println(time.Now())
	return &pb.HealthReply{
		Message: "{\"health\": \"ok\"}",
	}, nil
}

func main() {
	h := &handler{}
	lis, err := net.Listen("tcp", ":8080")
	if err != nil {
		log.Fatal(fmt.Sprintf("failed to listen: %v", err))
	}

	s := grpc.NewServer()
	pb.RegisterSampleServer(s, h)

	s.Serve(lis)
}
