package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"
	pb "github.com/kokoichi206/cloud-prac/kube/kind/protobuf/gen/go/protobuf"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

const (
	// api が動くディレクトリからの相対パス。
	tmpDir = "tmp"
)

func main() {
	ctx := context.Background()

	if err := os.Mkdir(tmpDir, 0777); err != nil {
		// log.Fatal("failed to create directory:", err)
		fmt.Println("failed to create directory:", err)
	}

	// grpc に接続する。
	host := "golang-grpc-server"
	port := "8080"

	// https://christina04.hatenablog.com/entry/grpc-client-side-lb
	// こちらの対応も必要！
	// resolver.SetDefaultScheme("dns")

	conn, err := grpc.DialContext(
		ctx,
		fmt.Sprintf("%s:%s", host, port),
		grpc.WithTransportCredentials(insecure.NewCredentials()),
		// grpc.WithDefaultServiceConfig(`{"loadBalancingConfig": [{"round_robin":{}}]}`),
	)
	if err != nil {
		log.Fatal("client connection error:", err)
	}

	gprcClient := pb.NewSampleClient(conn)

	// gin でサーバーをたてる。
	// 今回はポート 8080 でたてる。
	r := gin.Default()
	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status": "ok",
		})
	})

	r.GET("/go", func(c *gin.Context) {
		path := filepath.Join(tmpDir, fmt.Sprintf("%d", time.Now().UnixMilli()))
		f, err := os.Create(path)
		if err != nil {
			c.Error(err)
			return
		}
		defer f.Close()
		f.Write([]byte("accessed!"))

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
