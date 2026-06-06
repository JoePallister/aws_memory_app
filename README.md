
# Serverless API (Terraform + AWS Lambda)

This repository contains a Terraform-based, modular serverless API deployment for AWS. It provisions an API Gateway fronting a Lambda function with a DynamoDB backend, plus the necessary IAM roles. 

**Key Components**
- **Infrastructure:** modules under `modules/` for `apigateway`, `lambda`, `dynamodb`, and `iam`.
- **Lambda handler:** the function source is in `lambda/handler.py`.
- **Test scripts:** simple API smoke tests in `api_testing_scripts/`.

Getting started
---------------

1. Initialize Terraform:

```bash
terraform init
```

2. Review the plan:

```bash
terraform plan
```

3. Apply the plan:

```bash
terraform apply
```

After apply completes, the API endpoint and other outputs are available from Terraform outputs.

Testing the deployed API
------------------------
After deployment, the test scripts can be used to exercise the API.