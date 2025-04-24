![alt text](/resource/PRISMA_CLOUD_LOGO_color_dark_background.png?raw=true)
# AWS Vulnerable Infrastructure Setup for Hands-On Lab
This Terraform script automates the deployment of a vulnerable infrastructure. It provisions all the required AWS resources, including a custom VPC, EKS Cluster, Ubuntu EC2 instance, etc. The script configures the infrastructure to be publicly accessible, and AWS Cloudshell. 

Note: This is a vulnerable infrastructure, designed for hands-on lab or testing purposes. Do not use this for production.

### Terraform Resources
- EKS Cluster
- Ubuntu EC2 Instance
- S3 Bucket with sensitive data
- Keypair to access the Ubuntu EC2 instance
- Required network infrastructure, including VPC, subnet, route table, security group, etc
- Required IAM roles for access and provisioning

### Prerequisites
- Terraform installed
- AWS credentials configured (via `~/.aws/credentials` or environment variables) or using AWS Cloudshell
- AWS account with appropriate permissions for VPC, ECS, and IAM
- ```kubectl``` to access EKS cluster


### Usage

1. Clone the repository to your local directory or AWS Cloudshell:

    ```
    bash
    git clone https://github.com/chiangyaw/aws-vul-infra-setup.git
    cd aws-vul-infra-setup
    ```

2. Initialize Terraform:
    ```
    terraform init
    ```

3. Apply the Terraform script:
    ```
    terraform apply --auto-approve
    ```

4. After the deployment is completed, you'll be get the public IP of the EC2 Instance and other relevant information as an output:
    ```
    eks_cluster_name = "chiangyaw-eks-cluster"
    keypair_file = "keypair.pem"
    region = "ap-southeast-2"
    s3_bucket_name = "chiangyaw-sensitive-data-bucket-26w5gy"
    ubuntu_public_ip = "3.106.181.137"
    ```

5. Access Ubuntu EC2 instance via ```ssh```.
    ```
    ssh -i keypair.pem ubuntu@<ubuntu_public_ip>

    ```

6. To access AWS EKS cluste via ```kubectl```, you will first need to update kubeconfig via AWS CLI with the following:
    ```
    aws eks update-kubeconfig --region <your region> --name <eks-cluster-name>
    ```

### Cleanup
Once you are done with the lab, you can remove the deployed infrastructure with the following:

    ```
    terraform destroy --auto-approve
    ```

