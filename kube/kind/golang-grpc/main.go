package main

import (
	"context"
	"fmt"
	"log"
	"math"
	"net"
	"time"

	pb "github.com/kokoichi206/cloud-prac/kube/kind/protobuf/gen/go/protobuf"
	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"
)

type handler struct {
	pb.UnimplementedSampleServer
}

func (h *handler) Health(ctx context.Context, in *pb.HealthRequest) (*pb.HealthReply, error) {
	// log.Println(time.Now())

	// CPU を 10 秒間使い続ける。
	go func(ctx context.Context) {
		x := 246.0
		defer func() {
			fmt.Printf("x: %v\n", x)
		}()
		for {
			select {
			case <-ctx.Done():
				return
			default:
			}
			x += math.Sqrt(x)
		}
	}(ctx)
	time.Sleep(7 * time.Second)

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

	s := grpc.NewServer(
		grpc.KeepaliveParams(keepalive.ServerParameters{
			MaxConnectionAge: 60 * time.Second,
		}),
	)
	pb.RegisterSampleServer(s, h)

	s.Serve(lis)
}
