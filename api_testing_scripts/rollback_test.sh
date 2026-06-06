API=$(terraform output -raw api_endpoint)

curl -X POST "$API/releases/web-app/rollback"