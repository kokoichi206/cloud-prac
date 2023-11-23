package main

import (
	"context"
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
	pb "github.com/kokoichi206/cloud-prac/kube/kind/protobuf/gen/go/protobuf"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	ctx := context.Background()

	// grpc に接続する。
	host := "golang-grpc-server"
	port := "8080"

	conn, err := grpc.DialContext(
		ctx,
		fmt.Sprintf("%s:%s", host, port),
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		log.Fatal("client connection error:", err)
	}

	gprcClient := pb.NewSampleClient(conn)

	// gin でサーバーをたてる。
	// 今回はポート 8080 でたてる。
	r := gin.Default()
	r.GET("/", func(c *gin.Context) {
		ctx := c.Request.Context()
		res, err := gprcClient.Health(ctx, &pb.HealthRequest{})
		if err != nil {
			c.Error(err)
			return
		}
		c.JSON(200, gin.H{
			"message": res.Message,
		})
	})
	r.Run(":8080")
}
