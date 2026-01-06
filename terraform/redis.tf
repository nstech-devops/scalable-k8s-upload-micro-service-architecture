resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-subnet-group"
  subnet_ids = [
    aws_subnet.private_1.id,
  ]
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "upload-service-redis"
  description                = "Redis for Laravel Horizon queues"

  engine                     = "redis"
  engine_version             = "7.0"

  node_type                  = "cache.t3.micro"
  num_cache_clusters         = 2           # Multi-AZ — no single point of failure

  automatic_failover_enabled = true
  multi_az_enabled           = true

  subnet_group_name          = aws_elasticache_subnet_group.redis.name

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
}


output "redis_primary_endpoint" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}