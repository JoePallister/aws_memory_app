
# Anki-style Spaced Repetition Service (AWS)

A minimal Anki-like flashcard backend and frontend implemented with AWS-backed services and managed by Terraform. This repository contains infrastructure modules, Lambda handlers, a small static frontend, and API testing scripts used to demonstrate a spaced-repetition workflow.

Key features
- Terraform-managed AWS infrastructure (API Gateway, EventBridge, Lambda, DynamoDB, IAM).
- Lambda-based handlers for creating cards, scheduling reviews, and interval incrementing.
- Simple static frontend for manual review and due cards.
- Example API test scripts for quick integration checks.

Repository layout
- [main.tf](main.tf) — top-level Terraform that composes modules and deploys the stack.
- [modules](modules) — Terraform modules for `apigateway`, `dynamodb`, `iam`, and `lambda`.
- [src](src) — Lambda handler code:
	- [src/cards/create/handler.py](src/cards/create/handler.py)
	- [src/interval_increment/handler.py](src/interval_increment/handler.py)
	- [src/review_scheduler/handler.py](src/review_scheduler/handler.py)
- [frontend](frontend) — static HTML/JS/CSS UI for reviewing and creating cards.
- [api_testing_scripts](api_testing_scripts) — example scripts: `post_test.sh`, `get_test.sh`, `patch_test.sh`.
- `variables.tf`, `terraform.tfstate` — Terraform variables and state (local state included here for demos).

Quick start (deploy to AWS)
Prerequisites:
- Install Terraform (v1.x+)
- Configure AWS CLI credentials with an account that can create IAM, Lambda, API Gateway, and DynamoDB resources

Basic deploy
```bash
terraform init
terraform apply
```

After `apply` completes you will see outputs including the API Gateway endpoint. Use the endpoint to run the scripts in `api_testing_scripts` or point the frontend to it.

Local frontend
The frontend is static files; you can open `frontend/index.html` directly in a browser for a simple demo, or serve it with a static server:
```bash
cd frontend
python3 -m http.server 8000
# then open http://localhost:8000
```

API and handlers
- API routes are defined via Terraform in the `modules/apigateway` module.
- Lambda handlers are located in `src/` and implement card creation, review scheduling, and interval incrementing logic.
- Use the scripts in `api_testing_scripts` to exercise the API quickly.

Development notes
- To modify a Lambda, edit the corresponding file under `src/`, update deployment packaging (if any), and re-run `terraform apply` to push changes.

Testing
- Basic API tests: `./api_testing_scripts/post_test.sh`, `./api_testing_scripts/get_test.sh`, `./api_testing_scripts/patch_test.sh` — update the endpoint variable at the top of each script after deploy.

