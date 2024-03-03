# Add a record to the domain
resource "cloudflare_record" "test" {
  zone_id = var.cloudflare_zone_id
  name    = "test"
  value   = var.subdomain_ipv4
  type    = "A"
  ttl     = 3600
}
