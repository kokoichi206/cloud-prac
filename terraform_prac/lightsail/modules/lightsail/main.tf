locals {
  db_user     = "dbmasteruser"
  db_password = ""
  db_name     = "snsdb"
}

resource "aws_lightsail_container_service" "sns_service" {
  name        = "${var.prefix}-${var.env}"
  power       = "nano"
  scale       = 1
  is_disabled = false

  tags = {
    terraform = ""
  }
}

resource "aws_lightsail_container_service_deployment_version" "sns_app" {
  container {
    container_name = "${var.prefix}-backend"
    image          = ":${aws_lightsail_container_service.sns_service.name}.${var.env}.13"

    command = []

    environment = {
      SERVER_PORT                = "8080"
      CORS_ALLOW_ORIGIN          = "https://sns-app-b565d.web.app"
      DB_HOST      = "${aws_lightsail_database.sns_db.master_endpoint_address}"
      DB_PORT      = "5432"
      DB_USER      = "${local.db_user}"
      DB_NAME      = "${local.db_name}"
      DB_PASSWORD  = "${local.db_password}"
      DB_SSL_MODE  = "require"
    }

    ports = {
      8080 = "HTTP"
    }
  }

  public_endpoint {
    container_name = "${var.prefix}-backend"
    container_port = 8080

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout_seconds     = 2
      interval_seconds    = 5
      path                = "/api/v1/health"
      success_codes       = "200-499"
    }
  }

  service_name = aws_lightsail_container_service.sns_service.name
}

resource "aws_lightsail_database" "sns_db" {
  relational_database_name = "${var.prefix}-${var.env}-db"
  availability_zone        = "ap-northeast-1a"
  master_database_name     = local.db_name
  master_password          = local.db_password
  master_username          = local.db_user
  blueprint_id             = "postgres_15"
  bundle_id                = "micro_2_0"
  publicly_accessible      = true
  skip_final_snapshot      = true
  apply_immediately        = true
}
