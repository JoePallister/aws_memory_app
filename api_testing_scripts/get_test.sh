API=$(terraform output -raw api_endpoint)

curl "$(terraform output -raw api_endpoint)/releases/web-app"