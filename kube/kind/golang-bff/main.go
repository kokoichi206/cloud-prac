package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"strconv"

	"github.com/gin-gonic/gin"
	pb "github.com/kokoichi206/cloud-prac/kube/kind/protobuf/gen/go/protobuf"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/resolver"
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
	resolver.SetDefaultScheme("dns")

	// const MAX_WINDOW_SIZE int32 = (1 << 24)
	const MAX_WINDOW_SIZE int32 = (1 << 27)
	fmt.Printf("MAX_WINDOW_SIZE: %v\n", MAX_WINDOW_SIZE)

	conn, err := grpc.DialContext(
		ctx,
		fmt.Sprintf("%s:%s", host, port),
		grpc.WithTransportCredentials(insecure.NewCredentials()),
		grpc.WithDefaultServiceConfig(`{"loadBalancingConfig": [{"round_robin":{}}]}`),

		// grpc.WithInitialWindowSize(MAX_WINDOW_SIZE),
		// grpc.WithInitialConnWindowSize(MAX_WINDOW_SIZE),
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

	r.GET("/go/small", func(c *gin.Context) {
		// path := filepath.Join(tmpDir, fmt.Sprintf("%d", time.Now().UnixMilli()))
		// f, err := os.Create(path)
		// if err != nil {
		// 	c.Error(err)
		// 	return
		// }
		// defer f.Close()
		// f.Write([]byte("accessed!"))

		ctx := c.Request.Context()
		msg, err := gprcClient.Health(ctx, &pb.HealthRequest{
			SizeKb: 31,
		})
		if msg != nil {
			fmt.Printf("len(msg): %v\n", len(msg.Message))
			if len(msg.Message) < 1000 {
				fmt.Printf("msg.Message: %v\n", msg.Message)
			}
		}
		if err != nil {
			fmt.Println("error:", err)
			c.JSON(500, gin.H{
				"message": fmt.Sprintf("error at grpc client: %v", err),
			})
			return
		}
		c.JSON(200, gin.H{
			"message": "ok",
			// "message": res.Message,
		})
	})

	r.GET("/go/large", func(c *gin.Context) {
		ctx := c.Request.Context()
		msg, err := gprcClient.Health(ctx, &pb.HealthRequest{
			SizeKb: 33,
		})
		if msg != nil {
			fmt.Printf("len(msg): %v\n", len(msg.Message))
			if len(msg.Message) < 1000 {
				fmt.Printf("msg.Message: %v\n", msg.Message)
			}
		}
		if err != nil {
			fmt.Println("error:", err)
			c.JSON(500, gin.H{
				"message": fmt.Sprintf("error at grpc client: %v", err),
			})
			return
		}
		c.JSON(200, gin.H{
			"message": "ok",
		})
	})

	r.GET("/go/large-large", func(c *gin.Context) {
		ctx := c.Request.Context()
		msg, err := gprcClient.Health(ctx, &pb.HealthRequest{
			SizeKb: 1000,
		})
		if msg != nil {
			fmt.Printf("len(msg): %v\n", len(msg.Message))
			if len(msg.Message) < 1000 {
				fmt.Printf("msg.Message: %v\n", msg.Message)
			}
		}
		if err != nil {
			fmt.Println("error:", err)
			c.JSON(500, gin.H{
				"message": fmt.Sprintf("error at grpc client: %v", err),
			})
			return
		}
		c.JSON(200, gin.H{
			"message": "ok",
		})
	})

	r.GET("/go/", func(c *gin.Context) {
		s := c.Query("size")
		size, err := strconv.Atoi(s)
		if err != nil {
			c.JSON(400, gin.H{
				"message": fmt.Sprintf("invalid size (size = %s)", s),
			})
			return
		}

		ctx := c.Request.Context()
		msg, err := gprcClient.Health(ctx, &pb.HealthRequest{
			SizeKb: int64(size),
		})

		if msg != nil {
			fmt.Printf("len(msg): %v\n", len(msg.Message))
			if len(msg.Message) < 1000 {
				fmt.Printf("msg.Message: %v\n", msg.Message)
			}
		}
		if err != nil {
			fmt.Println("error:", err)
			c.JSON(500, gin.H{
				"message": fmt.Sprintf("error at grpc client: %v", err),
			})
			return
		}
		c.JSON(200, gin.H{
			"message": "ok",
		})
	})

	r.Run(":8080")
}
