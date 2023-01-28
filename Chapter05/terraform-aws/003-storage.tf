# Create EFS File System
resource "aws_efs_file_system" "efs" {
  creation_token = "${var.name}-${var.environment_type}-nfs"
  tags           = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-efs" }))
}

# Add a mount target for web01 subnet
resource "aws_efs_mount_target" "efs_mount_targets01" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.web01.id
  security_groups = [aws_security_group.sg_efs.id]
}

# Add a mount target for web02 subnet
resource "aws_efs_mount_target" "efs_mount_targets02" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.web02.id
  security_groups = [aws_security_group.sg_efs.id]
}