resource "aws_iam_policy" "s3_policy" {
  name = "${var.unique_prefix}-S3FullAccess"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect = "Allow",
        Action = "s3:*",
        Resource = [
          aws_s3_bucket.sensitive_data.arn,
          "${aws_s3_bucket.sensitive_data.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ubuntu_instance_role" {
  name = "${var.unique_prefix}-ubuntuInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ubuntu_role_attachment" {
  role       = aws_iam_role.ubuntu_instance_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_instance_profile" "ubuntu_profile" {
  name = "${var.unique_prefix}-ubuntuProfile"
  role = aws_iam_role.ubuntu_instance_role.name
}

resource "aws_iam_role" "eks_cluster_role" {
 name = "${var.unique_prefix}-eksClusterRole"

 path = "/"

 assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "eks.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.eks_cluster_role.name
}


resource "aws_iam_role" "eks_node_role" {
  name = "${var.unique_prefix}-eksNodeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_role_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

 resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.eks_node_role.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.eks_node_role.name
 }

 resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.eks_node_role.name
 }




