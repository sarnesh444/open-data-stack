variable "aws_region" {
  description = "AWS Region to deploy to"
  default     = "us-east-2"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  default     = "t3.xlarge"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 24.04 LTS (Update this for your region!)"
  default     = "ami-0c995fbcf99222492" # Example for us-east-2, Ubuntu 24.04
}

variable "key_name" {
  description = "Name of the SSH key pair to use"
}

variable "repo_url" {
  description = "Git repository URL to clone"
}
