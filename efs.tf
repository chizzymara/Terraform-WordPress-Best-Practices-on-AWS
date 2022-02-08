resource "aws_efs_file_system" "wordpress-efs" {
  creation_token   = "wordpress-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"
  tags = {
    Name = "wordpress-efs"
  }
}

resource "aws_efs_mount_target" "efs-mount-az1" {
  file_system_id  = aws_efs_file_system.wordpress-efs.id
  subnet_id       = aws_subnet.data-subnet-az1.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "efs-mount-az2" {
  file_system_id  = aws_efs_file_system.wordpress-efs.id
  subnet_id       = aws_subnet.data-subnet-az2.id
  security_groups = [aws_security_group.efs.id]
}