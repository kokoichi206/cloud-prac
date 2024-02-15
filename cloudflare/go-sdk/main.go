package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func s3api() {
	accountID := os.Getenv("ACCOUNT_ID")
	endpoint := fmt.Sprintf("https://%s.r2.cloudflarestorage.com", accountID)
	bucket := "my-first-bucket"
	object := "aya2.png"

	resolver := aws.EndpointResolverWithOptionsFunc(func(service, region string, opts ...interface{}) (aws.Endpoint, error) {
		return aws.Endpoint{
			URL:               endpoint,
			HostnameImmutable: true,
			SigningRegion:     region,
		}, nil
	})

	cfg, err := config.LoadDefaultConfig(
		context.TODO(),
		// config.WithRegion("APAC"),
		config.WithRegion("auto"),
		config.WithEndpointResolverWithOptions(resolver),
	)
	if err != nil {
		log.Fatal(err)
	}

	// **aws の** s3 client を作成する。
	client := s3.NewFromConfig(cfg)

	f, _ := os.Open("upload_test.jpg")
	out, err := client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String("upload_test.jpg"),
		Body:   f,
	})
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("out: %v\n", out)

	// ========= Get an object =========
	obj, err := client.GetObject(context.TODO(), &s3.GetObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(object),
	})
	if err != nil {
		log.Fatal(err)
	}

	writeFile(obj.Body)
}

func writeFile(body io.ReadCloser) {
	defer body.Close()

	f, err := os.Create("test.png")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	io.Copy(f, body)
}

func main() {
	s3api()
	return
	// // Construct a new API object using a global API key
	// api, err := cloudflare.New(os.Getenv("CLOUDFLARE_API_KEY"), os.Getenv("CLOUDFLARE_API_EMAIL"))
	// // alternatively, you can use a scoped API token
	// // api, err := cloudflare.NewWithAPIToken(os.Getenv("CLOUDFLARE_API_TOKEN"))
	// if err != nil {
	// 	log.Fatal(err)
	// }

	// // Most API calls require a Context
	// ctx := context.Background()

	// // Fetch user details on the account
	// u, err := api.UserDetails(ctx)
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// // Print user details
	// fmt.Printf("u: %+v\n", u)

	// // api.ListR2Buckets(ctx, &cloudflare.ResourceContainer{}, cloudflare.ListR2BucketsParams{})
	// buckets, err := api.ListR2Buckets(ctx, &cloudflare.ResourceContainer{
	// 	Identifier: "bc003a008ecb84ab15327f6ffe1c558f",
	// }, cloudflare.ListR2BucketsParams{})
	// api.GetR2Bucket(ctx, &cloudflare.ResourceContainer{
	// 	Identifier: "bc003a008ecb84ab15327f6ffe1c558f",
	// }, "test-bucket")

	// fmt.Printf("err: %v\n", err)
	// fmt.Printf("len(buckets): %v\n", len(buckets))
	// for _, bucket := range buckets {
	// 	fmt.Printf("bucket: %+v\n", bucket)
	// }
}
