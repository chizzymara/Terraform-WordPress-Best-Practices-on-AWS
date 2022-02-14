resource "aws_elasticache_subnet_group" "memcache-subnet-group" {
  name       = "wordpress-cache-subnet"
  subnet_ids = [aws_subnet.data-subnet-az1.id, aws_subnet.data-subnet-az2.id]
}

resource "aws_elasticache_parameter_group" "default" {
  name   = "memcached-paremeter-group"
  family = "memcached1.6"
}

resource "aws_elasticache_cluster" "wordpress" {
  cluster_id                   = "wordpress"
  engine                       = "memcached"
  node_type                    = "cache.t2.micro"
  num_cache_nodes              = 2
  parameter_group_name         = aws_elasticache_parameter_group.default.name
  port                         = 11211
  preferred_availability_zones = ["eu-central-1a", "eu-central-1b"]
  az_mode                      = "cross-az"
  subnet_group_name            = aws_elasticache_subnet_group.memcache-subnet-group.name
  security_group_ids           = [aws_security_group.memcached.id, ]
}

resource "time_sleep" "wait_150_seconds" {
  depends_on = [aws_elasticache_cluster.wordpress]

  create_duration = "150s"
}
