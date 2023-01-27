data "aws_ami" "ubuntu_web" {
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

resource "aws_launch_configuration" "web_launch_configuration" {
  name_prefix                 = "${var.name}-${var.environment_type}-alc-web-"
  image_id                    = data.aws_ami.ubuntu_web.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  security_groups             = [aws_security_group.sg_vms.id]
  user_data = templatefile("vm-cloud-init-web.yml.tftpl", {
    tmpl_file_share = "${aws_efs_file_system.efs.dns_name}"
  })
}

resource "aws_autoscaling_group" "web_autoscaling_group" {
  name                 = "${var.name}-${var.environment_type}-asg-web"
  min_size             = var.min_number_of_web_servers
  max_size             = var.max_number_of_web_servers
  launch_configuration = aws_launch_configuration.web_launch_configuration.name
  target_group_arns    = [aws_lb_target_group.front_end.arn]
  vpc_zone_identifier  = [aws_subnet.web01.id, aws_subnet.web02.id]

  lifecycle {
    create_before_destroy = true
  }
}