resource "aws_elasticache_subnet_group" "memcache-subnet-group" {
  name       = "wordpress-cache-subnet"
  subnet_ids = [aws_subnet.data-subnet-az1.id , aws_subnet.data-subnet-az2.id]
}

#resource "aws_elasticache_security_group" "security-group-memcache" {
#  name                 = "elasticache-security-group"
#  security_group_names = [aws_security_group.bastion-guest.name]
#}

resource "aws_elasticache_parameter_group" "default" {
  name   = "memcached-paremeter-group"
  family = "memcached1.4"

  parameter {
    name  = "max_item_size"
    value = "1"
  }
}

resource "aws_elasticache_cluster" "wordpress" {
  cluster_id           = "wordpress"
  engine               = "memcached"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 2
  parameter_group_name = aws_elasticache_parameter_group.default.name
  port                 = 11211
  preferred_availability_zones    = [ "eu-central-1a", "eu-central-1b" ]
  az_mode              = "cross-az"
  subnet_group_name    = aws_elasticache_subnet_group.memcache-subnet-group.name
  #security_group_ids = [aws_elasticache_security_group.security-group-memcache.id, ]
}


