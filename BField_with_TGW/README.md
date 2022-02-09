Please see https://unofficialaciguide.com

Used for POC:  Cisco Cloud ACI Generic External Connectivity.  https://unofficialaciguide.com/2022/01/20/cisco-cloud-aci-generic-external-connectivity/

This spins up a VPC, IGW & EC2.  ssh keys are imported from local machine you are using

# Usage:
```
git clone https://github.com/soumukhe/Terraform-aws-physical-dummy.git
cd Terraform-aws-physical-dummy
modify the overfide.tf file and put in your aws credentials for the account where this will be spun up (could be the same ACI tenant account)
modify terraform.tfvars file as needed
terraform init
terraform validate
terraform apply
```
