data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
resource "aws_iam_role" "bastion_iam_role" {
  name = "hw-bastion-iam-role"

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3FullAccess"]

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  lifecycle {
    ignore_changes = [
      managed_policy_arns,
    ]
  }
}
resource "aws_iam_policy" "bastion_task_policy" {
  name        = "BastionTaskPolicy"
  description = "Policy to allow uploading and retrieving data from S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
          "ssm:GetParameters",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          "*",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_access_policy" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = aws_iam_policy.bastion_task_policy.arn
}

resource "aws_iam_instance_profile" "bastion_iam_instance_profile" {
  name = "hw-bastion-iam-instance-profile"
  role = aws_iam_role.bastion_iam_role.name
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amzlinux2.id
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.bastion_iam_instance_profile.name
  subnet_id                   = var.app_subnet_a_id
  associate_public_ip_address = false

  vpc_security_group_ids = [
    var.app_sg_id
  ]
  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }


  tags = {
    Name = "hw-ec2"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}