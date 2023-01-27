output "wp_password" {
  value     = "Wordpress Admin Password: ${random_password.wordpress_admin_password.result}"
  sensitive = true
}

output "wp_url" {
  value     = "Wordpress URL: http://${aws_lb.lb.dns_name}/"
  sensitive = false
}
