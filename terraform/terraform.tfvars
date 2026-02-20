# Update values only if they differ in your account/environment.
region                = "us-east-1"
instance_type         = "t3.micro"
key_name              = "microservices-key"
instance_profile_name = "ec2-ecr-pull-role"
ec2_security_group_id = "sg-0e45d0e343ac66f64"

public_subnet_ids = [
  "subnet-0de3a6ed7747531b6",
  "subnet-086be7b6483761a93"
]

target_group_service1_name = "tg-service1"
target_group_service2_name = "tg-service2"

asg_name             = "microservices-asg"
launch_template_name = "microservices-lt"

cpu_scale_out_threshold          = 40
cpu_scale_out_evaluation_periods = 5
cpu_scale_out_cooldown_seconds   = 300
