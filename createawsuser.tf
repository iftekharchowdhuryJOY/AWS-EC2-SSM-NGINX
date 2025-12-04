provider "aws" {
  region = "ca-central-1"
}

# Create IAM user
resource "aws_iam_user" "new_user" {
  name = "testuserjoy"
  force_destroy = true
}

# Create IAM group
resource "aws_iam_group" "devops" {
  name = "DevOpsEngineers"
}

# Attach AWS managed policy to group
resource "aws_iam_group_policy_attachment" "devops_poweruser" {
  group      = aws_iam_group.devops.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# Add user to group
resource "aws_iam_user_group_membership" "joy_membership" {
  user = aws_iam_user.joy.name
  groups = [
    aws_iam_group.devops.name
  ]
}

# OPTIONAL: Create access key (DON'T DO IN PROD unless needed)
resource "aws_iam_access_key" "key" {
  user = aws_iam_user.joy.name
}

output "access_key_id" {
  value = aws_iam_access_key.key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.key.secret
  sensitive = true
}
