# module "eks" {
#   source          = "terraform-aws-modules/eks/aws"
#   cluster_name    = "${var.unique_prefix}-eks-cluster"
#   cluster_version = "1.28"
#   subnets         = [aws_subnet.main_subnet.id]
#   vpc_id          = aws_vpc.main.id

#   node_groups = {
#     default = {
#       desired_capacity = 1
#       max_capacity     = 1
#       min_capacity     = 1

#       instance_types = ["t3.large"]
#       iam_role_arn   = aws_iam_role.eks_node_role.arn
#     }
#   }
# }

resource "aws_eks_cluster" "eks_cluster" {
 name = "${var.unique_prefix}-eks-cluster"
 role_arn = aws_iam_role.eks_cluster_role.arn
 vpc_config {
  subnet_ids = [aws_subnet.main_subnet_a.id, aws_subnet.main_subnet_b.id]
  endpoint_public_access = true
  public_access_cidrs = ["0.0.0.0/0"]
 }
}

 resource "aws_eks_node_group" "worker_node_group" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  node_group_name   = "${var.unique_prefix}-workernodes"
  node_role_arn     = aws_iam_role.eks_node_role.arn
  subnet_ids        = [aws_subnet.main_subnet_a.id, aws_subnet.main_subnet_b.id]
  instance_types    = ["t3.xlarge"]

    tags = {
    Name   = "${var.unique_prefix}-eks-worker"
    DND = "DND"
    StatusDND = "DND"
  }
 
  scaling_config {
   desired_size = 1
   max_size   = 1
   min_size   = 1
  }
 
  depends_on = [
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,

  ]

 }

# data "aws_eks_cluster_auth" "eks_auth" {
#   name = aws_eks_cluster.eks_cluster.name
# }

# resource "kubernetes_manifest" "cdr_deploy" {
#   manifest = yamldecode(data.http.cdr_yaml.body)
# }

# data "http" "cdr_yaml" {
#   url = "https://raw.githubusercontent.com/hankthebldr/CDR/refs/heads/master/cdr.yml"
# }

resource "null_resource" "apply_cdr_yaml" {
  depends_on = [aws_eks_node_group.worker_node_group]

  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --name ${aws_eks_cluster.eks_cluster.name} --region ${var.region}
      kubectl apply -f https://raw.githubusercontent.com/hankthebldr/CDR/refs/heads/master/cdr.yml
    EOT
  }
}


