resource "aws_cloudfront_distribution" "worpress-cloud-front" {
  depends_on = [
    aws_lb.wordpress_load_balancer
  ]
  origin {
    domain_name = aws_lb.wordpress_load_balancer.dns_name
    origin_id   = "web-frontend"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }
  enabled = true
  restrictions {
    geo_restriction {
      restriction_type = "none"
      #locations        = ["US", "CA", "GB", "DE"]
    }
  }
  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]
    #same as the origin id of the cloudfront should probably turn it to a local
    target_origin_id = "web-frontend"

    forwarded_values {
      query_string = false
      headers      = ["host"]

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

  }
  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:626205521754:certificate/7655a6fa-4601-4e8e-87d3-354c0c301440"
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }
}