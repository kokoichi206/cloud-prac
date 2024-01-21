package main

import (
	"bytes"
	"context"
	"fmt"
	"log"
	"math"
	"math/rand"
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
	// why this is not working?
	time.Sleep(30 * time.Second)

	return &pb.HealthReply{
		// Message: "{\"health\": \"ok\"}",
		Message: createLargeResponse(int(in.SizeKb)),
	}, nil
}

func main() {
	h := &handler{}
	lis, err := net.Listen("tcp", ":8080")
	if err != nil {
		log.Fatal(fmt.Sprintf("failed to listen: %v", err))
	}

	const MAX_BUFFER_SIZE int = (1 << 27)
	fmt.Printf("MAX_BUFFER_SIZE: %v\n", MAX_BUFFER_SIZE)

	s := grpc.NewServer(
		grpc.KeepaliveParams(keepalive.ServerParameters{
			MaxConnectionAge: 15 * time.Second,
		}),

		// grpc.ReadBufferSize(MAX_BUFFER_SIZE),
		// grpc.WriteBufferSize(MAX_BUFFER_SIZE),
	)
	pb.RegisterSampleServer(s, h)

	s.Serve(lis)
}

func createLargeResponse(sizeKb int) string {
	// size := sizeMb * 1024 * 1024
	// random fluctuation
	size := sizeKb*1024 + 321

	// ランダムな文字列を生成するための文字セット
	const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

	var seededRand *rand.Rand = rand.New(rand.NewSource(time.Now().UnixNano()))

	var buffer bytes.Buffer
	buffer.Grow(size)

	for buffer.Len() < size {
		buffer.WriteByte(charset[seededRand.Intn(len(charset))])
	}

	return buffer.String()
}
