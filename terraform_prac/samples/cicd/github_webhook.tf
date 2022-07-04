# コードの変更を通知する
resource "github_repository_webhook" "example" {
  repository = "cloud-prac"

  configuration {
    url          = aws_codepipeline_webhook.example.url
    secret       = "VeryRandomStringMoreThan20BYte"
    content_type = "json"
    insecure_ssl = false
  }

  events = ["push"]
}
