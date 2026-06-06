API=$(terraform output -raw api_endpoint)

curl -X POST \
"$API/releases/web-app" \
-H "Content-Type: application/json" \
-d '{
"user_id": "12"
}'