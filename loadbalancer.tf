
resource "aws_lb" "wordpress_load_balancer" {
  name               = "wordpress-load-balancer"
  internal           = false
  load_balancer_type = "application"
  depends_on = [
    aws_security_group.lb_sg, aws_instance.Wordpress_Instance, aws_autoscaling_group.wordpress_asg
  ]
  #have to make a security group for the lb 
  security_groups = [aws_security_group.lb_sg.id]
  subnets         = [aws_subnet.public-subnet-az1.id, aws_subnet.public-subnet-az2.id]

  enable_deletion_protection = false

  #access_logs {
  # bucket  = aws_s3_bucket.lb_logs.bucket
  #prefix  = "test-lb"
  #enabled = true
  #}

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "redirect" {
  load_balancer_arn = aws_lb.wordpress_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "forward" {
  load_balancer_arn = aws_lb.wordpress_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:eu-central-1:626205521754:certificate/14e5f190-39e6-4b66-8a0b-e242f6a93323"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wp-target-group.arn
  }
}