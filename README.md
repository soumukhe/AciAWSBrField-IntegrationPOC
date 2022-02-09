# AciAWSBrField-IntegrationPOC
Code for spinning up ACI Tenant,  Brownfield environment and EC2s for Brownfield Integration POC

Please see https://unofficialaciguide.com for full details

# This code has 3 directories
```
aci_tenant                 # Used to spin up an ACI Tenant with 1 VPC, 3 subnets with Transit Gateway Connecitivy to ACI Infra Tenant and other associated objects
awsEC2-onACI_Infra         # Please use the aci_tenant script first.  This script will spin up an ec2 with Apache installed on the ACI Tenant
BField_with_TGW            #  This script will create a Brownfield environment that you can then integrate with ACI Tenant.  
                               BrField will have 2 VPCs, Transit Gateway with attachments and routes.  1 EC2 will be spun up in each VPC and you can reach between
                               EC2s on private IP through the Transit gateway.
                             
```


* 📗 Note:  
1) In each directory there are 3 variable files:
   vars.tf,  terraform.tfvars and override.tf.
   Make sure to populate your AWS access-keys and secret keys in the overide.tf
   you can also change variable values in terraform.tfvars as you need to.  Feel free to also modify values in vars.tf if you want.
   
  2) When spinning up the ACI Tenant, make sure to first source the environment file "source ./FirstSourceParallelism.env".  This will setup the parallelism=1 env.
     After that you can use your terraform init/fmt/validate/plan/apply commands
     
  3) when spinning up EC2 on the ACI tenant, please first source the environment file: "source ./unset_env_first.env".  This will remove the parallelism env.
  
  
  Please see https://unofficialaciguide.com/(still working on writeup) for full step by step guide on ACI/AWS Brownfield Integration procedure.
