#creating an ami image off the wordpress instance
resource "aws_ami_from_instance" "ami_wordpress" {
  name               = "ami_wordpress_terraform"
  source_instance_id = aws_instance.Wordpress_Instance.id
  depends_on         = [aws_instance.Wordpress_Instance, time_sleep.wait_300_seconds]
}

#userdata template to mount efs
data "template_file" "efs-script" {
  template = file("efs-script.sh")
  depends_on = [
    aws_efs_file_system.wordpress-efs, aws_efs_mount_target.efs-mount-az1, aws_efs_mount_target.efs-mount-az2
  ]
  vars = {
    file_system_id = "${aws_efs_file_system.wordpress-efs.id}"
    region         = "${var.region1}"
  }
}

#creating a launch configuration based of ec2 ami
resource "aws_launch_configuration" "wordpress_config" {
  name            = "wordpress_config"
  image_id        = aws_ami_from_instance.ami_wordpress.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.bastion-guest.id, ]
  user_data       = data.template_file
  depends_on = [
    aws_instance.Wordpress_Instance,
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

}

#resource "aws_lb_target_group_attachment" "TG-attachement" {
#  target_group_arn = aws_lb_target_group.wp-target-group.arn
#   target_id        = aws_lb.wordpress_load_balancer.arn
#  port             = 80
#}

#creating the autoscaling group
resource "aws_autoscaling_group" "wordpress_asg" {
  name                      = "wordpress_asg"
  max_size                  = var.asg-max-size
  min_size                  = var.asg-min-size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.asg-desired-size
  depends_on = [
    aws_instance.Wordpress_Instance,
  ]
  #force_delete              = true
  launch_configuration = aws_launch_configuration.wordpress_config.name
  vpc_zone_identifier  = [aws_subnet.app-subnet-az1.id, aws_subnet.app-subnet-az1.id]
  target_group_arns    = [aws_lb_target_group.wp-target-group.arn]
}
