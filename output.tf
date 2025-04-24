output "ubuntu_public_ip" {
  value       = aws_instance.ubuntu_instance.public_ip
}
output "s3_bucket_name" {
  value       = aws_s3_bucket.sensitive_data.bucket
}
output "keypair_file" {
  value       = local_file.ssh_key.filename
}
output "region" {
    value   =   var.region
}
output "eks_cluster_name"{
    value = aws_eks_cluster.eks_cluster.name
}