# ci-cd-pipeline-project

## Introduction
This project is aimed at creating a simple deployment pipeline. It is not the ideal pipeline for production environments, but a starting point to get a foretaste of what deployment automation looks like. The pipeline will create the environment for the application to run and also deploy the application. The application is a simple one-page web application.

## Requirements
•	AWS account
•	Terraform CLI

## Procedure
The deployv2.sh is a bash script that, when run in a Linux environment, installs updates for Linux, Apache, and git. It then clones the repository defined and copies the content of the repository to the appropriate directory (var/www/html). The index.html can then be displayed as a web page.

The Terraform configuration, infra.tf, creates the deployment environment. The infrastructure is created on AWS. When infra.tf is run, it creates a VPC in the us-east-2 region with:
•	a CIDR block
•	2 private and 2 public subnets
•	route table and its association with designated subnets,
•	a security group with ingress rules allowing http on port 80, https on port 443, SSH on port 22, and egress rules allowed on all ports.
•	2 EC2 instances launched inside a public subnet

The creation of the infrastructure and deployment of the application are accomplished by running mainly 2 Terraform commands.
•	`terraform init` : initializes the Terraform manifest. In this stage, providers and modules are downloaded.
•	`terraform validate` (optional): This checks if the Terraform configuration is valid. It echoes a success message if the configuration is valid or a failure message if the configuration is invalid. It also displays the lines where the error occurred and the reason(s).
•	`terraform apply`: This creates the items declared in the configuration. It displays a configuration plan and requires the user to confirm whether they agree or disagree with the plan. A "yes" will signal Terraform to execute the configuration, while a "no" will abort it.
•	`terraform destroy`: This is used to remove every item created in a Terraform configuration. 

**Note**: *The user must have installed Terraform CLI on their computer and set the AWS access key ID and Secret access key as environment variables for the AWS account they wish to use.*

## Result
When the configuration is applied, Terraform creates the infrastructure as defined in the configuration. The deployment script, *deployv2.sh*, is injected through the *user_data* input of EC2 and runs when the EC2 instances are created. The index page of the application can be viewed by visiting the *public IPv4 address* of any of the EC2 instances.

