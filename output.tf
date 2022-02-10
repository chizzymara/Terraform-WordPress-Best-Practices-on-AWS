output "Instance_public_ip" {
  description = "public ip address of the ec2 instance"
  value       = aws_instance.Wordpress_Instance.public_ip
}

output "lb_dns_name" {
  value = aws_lb.wordpress_load_balancer.dns_name
}

output "node-az1" {
  value = aws_elasticache_cluster.wordpress.cache_nodes
}

