package main

import "os"

func init() {
	os.Setenv("CLOUDFLARE_API_KEY", "your-api-key")
	os.Setenv("CLOUDFLARE_API_EMAIL", "your-email")

	// R2 Authentication: https://developers.cloudflare.com/r2/api/s3/tokens/
	os.Setenv("AWS_ACCESS_KEY_ID", "xxxxxxxxxxx")
	os.Setenv("AWS_SECRET_ACCESS_KEY", "xxxxxxxxxxx")

	os.Setenv("ACCOUNT_ID", "xxxxxxxxxxx")
}
