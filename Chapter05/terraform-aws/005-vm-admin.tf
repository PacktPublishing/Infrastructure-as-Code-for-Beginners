data "aws_ami" "ubuntu_admin" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "random_password" "wordpress_admin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_instance" "admin" {
  ami                         = data.aws_ami.ubuntu_admin.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.web01.id
  associate_public_ip_address = true
  availability_zone           = var.zones[0]
  vpc_security_group_ids      = [aws_security_group.sg_vms.id]

  user_data = templatefile("vm-cloud-init-admin.yml.tftpl", {
    tmpl_database_username = "${var.database_username}"
    tmpl_database_password = "${random_password.database_password.result}"
    tmpl_database_hostname = "${aws_db_instance.database.address}"
    tmpl_database_name     = "${var.database_name}"
    tmpl_file_share        = "${aws_efs_file_system.efs.dns_name}"
    tmpl_wordpress_url     = "http://${aws_lb.lb.dns_name}/"
    tmpl_wp_title          = "${var.wp_title}"
    tmpl_wp_admin_user     = "${var.wp_admin_user}"
    tmpl_wp_admin_password = "${random_password.wordpress_admin_password.result}"
    tmpl_wp_admin_email    = "${var.wp_admin_email}"
  })

  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-ec2-admin" }))
}

# Add instsance to the load balancer
resource "aws_lb_target_group_attachment" "admin" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = aws_instance.admin.id
  port             = 80
}