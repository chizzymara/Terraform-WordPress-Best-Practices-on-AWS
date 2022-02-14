output "Bastionhost_ip" {
  description = "public ip address of the ec2 instance"
  value       = aws_instance.Bastion.public_ip
}

output "lb_dns_name" {
  value = aws_lb.wordpress_load_balancer.dns_name
}

output "node-az1" {
  value = aws_elasticache_cluster.wordpress.cache_nodes
}

output "cloudfront_name" {
  value = aws_cloudfront_distribution.worpress-cloud-front.domain_name
}