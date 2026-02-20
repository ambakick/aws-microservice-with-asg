data "aws_caller_identity" "current" {}

data "aws_lb_target_group" "service1" {
  name = var.target_group_service1_name
}

data "aws_lb_target_group" "service2" {
  name = var.target_group_service2_name
}

resource "aws_launch_template" "microservices" {
  name                   = var.launch_template_name
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.ec2_security_group_id]

  iam_instance_profile {
    name = var.instance_profile_name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    region             = var.region
    account_id         = data.aws_caller_identity.current.account_id
    service1_repo_name = var.service1_repo_name
    service2_repo_name = var.service2_repo_name
  }))

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "microservices-asg-instance"
      Project = "devops-interview-assessment"
    }
  }

  tags = {
    Name    = var.launch_template_name
    Project = "devops-interview-assessment"
  }
}

resource "aws_autoscaling_group" "microservices" {
  name                      = var.asg_name
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 4
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = var.public_subnet_ids
  target_group_arns = [
    data.aws_lb_target_group.service1.arn,
    data.aws_lb_target_group.service2.arn
  ]

  launch_template {
    id      = aws_launch_template.microservices.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "microservices-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "devops-interview-assessment"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.asg_name}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.microservices.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = var.cpu_scale_out_cooldown_seconds
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.asg_name}-cpu-high"
  alarm_description   = "Scale out when ASG average CPU is above threshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = var.cpu_scale_out_evaluation_periods
  datapoints_to_alarm = var.cpu_scale_out_evaluation_periods
  threshold           = var.cpu_scale_out_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.microservices.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]

  tags = {
    Project = "devops-interview-assessment"
  }
}
