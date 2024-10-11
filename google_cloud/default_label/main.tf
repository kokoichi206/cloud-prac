provider "google" {
  project = "tf-prac-438213"
  region  = "asia-northeast1"

  default_labels = {
    app = "test-app"
  }
}

terraform {
  required_version = "~> 1.9.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.44.0"
    }
  }
}

data "google_client_config" "current" {
}

resource "google_sql_database_instance" "master" {
  name             = "test-app-db"
  database_version = "MYSQL_8_0"
  region           = "asia-northeast1"
  settings {
    tier = "db-f1-micro"

    // 各リソースの top 階層に label がない場合は default_labels が適応されない。
    // https://github.com/hashicorp/terraform-provider-google/issues/16375#issuecomment-2289955256
    user_labels = data.google_client_config.current.default_labels
  }
}
