# Terraform (Bonus)

This module provisions the bonus infrastructure with IaC:
- Launch Template with EC2 user-data (Docker + ECR pull + docker-compose)
- Auto Scaling Group (`min=2`, `desired=2`, `max=4`)
- Attachment to existing ALB target groups (`tg-service1`, `tg-service2`)
- CPU scale-out policy (`>40%` for 5 minutes)

## Prerequisites
- AWS CLI configured for the target account/region
- Existing resources from core setup:
  - `tg-service1`
  - `tg-service2`
  - EC2 security group (default: `sg-0e45d0e343ac66f64`)
  - IAM instance profile (default: `ec2-ecr-pull-role`)
  - ECR repos `service1` and `service2` with `latest` tags

## Usage
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Validate
- Check ASG created with desired capacity 2
- Check target groups show ASG instances as healthy
- Check CloudWatch alarm `${asg_name}-cpu-high`
- Check ASG scaling policy `${asg_name}-scale-out`

## Cleanup
```bash
terraform destroy
```
