resource "time_sleep" "wait_300_seconds" {
  depends_on = [aws_autoscaling_group.wordpress_asg]

  create_duration = "300s"
}

#userdata template to mount efs
data "template_file" "efs-script" {
  template = file("user-data.sh")
  depends_on = [
    aws_efs_file_system.wordpress-efs, aws_efs_mount_target.efs-mount-az1, aws_efs_mount_target.efs-mount-az2, aws_elasticache_cluster.wordpress
  ]
  vars = {
    file_system_id = "${aws_efs_file_system.wordpress-efs.id}"
    region         = "${var.region1}"
    node-az1       = "${element(aws_elasticache_cluster.wordpress.cache_nodes[*].address, 0)}"
    node-az2       = "${element(aws_elasticache_cluster.wordpress.cache_nodes[*].address, 1)}"
  }
}


#creating a launch configuration based of ec2 ami
resource "aws_launch_configuration" "wordpress_config" {
  name                 = "wordpress_config"
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.bastion-guest.id, ]
  iam_instance_profile = aws_iam_instance_profile.wordpress_instance_profile.name
  user_data            = data.template_file.efs-script.rendered
  depends_on = [
    data.aws_key_pair.key_pair, aws_nat_gateway.Nat-Az1, aws_nat_gateway.Nat-Az2, aws_subnet.app-subnet-az1, aws_network_acl.nacl, aws_route_table.wp_priv_route_table1, aws_route_table.wp_priv_route_table2,
    aws_route_table_association.c, aws_route_table_association.d, aws_efs_mount_target.efs-mount-az1, aws_efs_mount_target.efs-mount-az2
  ]
  key_name = data.aws_key_pair.key_pair.key_name
}

#target groups 
resource "aws_lb_target_group" "wp-target-group" {
  name        = "wp-target-group"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.wordpress.id
  health_check {
    path                = "/"
    healthy_threshold   = 6
    unhealthy_threshold = 10
    timeout             = 80
    interval            = 100
    matcher             = "200-399" # has to be HTTP 200 or fails
  }
}



#creating the autoscaling group
resource "aws_autoscaling_group" "wordpress_asg" {
  name                      = "wordpress_asg"
  max_size                  = var.asg-max-size
  min_size                  = var.asg-min-size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.asg-desired-size
  depends_on = [
    time_sleep.wait_150_seconds, aws_launch_configuration.wordpress_config
  ]
  #force_delete              = true
  launch_configuration = aws_launch_configuration.wordpress_config.name
  vpc_zone_identifier  = [aws_subnet.app-subnet-az1.id, aws_subnet.app-subnet-az1.id]
  target_group_arns    = [aws_lb_target_group.wp-target-group.arn]
}
