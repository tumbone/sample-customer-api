### Deploy a sample API to AWS ECS (Terraform)

#### Deploy the solution using Terraform
```
cd ./infra
terraform init
terraform apply
```
The step above will output the dns name of the AWS Application Load Balancer that can be used to invoke the api.

#### API routes
- /v1/devops/customers GET
- /v1/devops/customers?id=`<id>` GET
- /v1/devops/customers POST
- /v1/devops/customers/<id> DELETE