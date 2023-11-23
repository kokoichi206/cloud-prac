package main

import "github.com/gin-gonic/gin"

func main() {
	// gin でサーバーをたてる。
	// 今回はポート 8080 でたてる。
	r := gin.Default()
	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "Hello World",
		})
	})
	r.Run(":8080")
}
