variable "prefix" {
  type        = string
  default     = "sns-app-sample"
  description = "The prifix of the service"
}

variable "env" {
  type        = string
  default     = "production"
  description = "The environment where the service works (production, staging, development)"
}

variable "cloudflare_api_token" {
  // https://developers.cloudflare.com/fundamentals/api/get-started/create-token/
  type        = string
  description = "The API token for Cloudflare"
}

variable "cloudflare_zone_id" {
  // https://developers.cloudflare.com/fundamentals/setup/find-account-and-zone-ids/
  type        = string
  description = "The zone id of the domain"
}

variable "subdomain_ipv4" {
  type        = string
  description = "The IPv4 address of the subdomain"
}

variable "account_id" {
  type        = string
  description = "The account id of the service"
}
