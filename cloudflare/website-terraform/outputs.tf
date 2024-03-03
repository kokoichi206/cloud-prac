output "dns_url" {
  value       = "https://${cloudflare_record.test.hostname}"
  description = "URL of the DNS record"
}
