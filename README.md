# AWS Terraform ALB Lab

## Overview
This project demonstrates the deployment of AWS infrastructure using Terraform.

## Components deployed:
VPC
Public Subnets
Internet Gateway
Security Groups
EC2 Instances
Nginx Web Server
Application Load Balancer
Target Groups
Listener Rules

Built using Terraform on AWS.

## Architecture

For ALB Project
Internet
    │
    ▼
ALB
    │
 ┌──┴──┐
 ▼     ▼
EC2   EC2
Nginx Nginx

## Deployment Steps
terraform init
terraform plan
terraform apply

## Validation
Verified EC2 accessibility
Verified Nginx web page
Verified ALB DNS endpoint
Verified traffic routing to backend instances

## Lessons Learned
Terraform workflow
AWS networking fundamentals
ALB traffic distribution
Security Group design
Nginx deployment
Troubleshooting connectivity issues
