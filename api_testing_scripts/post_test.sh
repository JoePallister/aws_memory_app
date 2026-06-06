API=$(terraform output -raw api_endpoint)

curl -X POST \
"$API/releases/web-app" \
-H "Content-Type: application/json" \
-d '{
"version": "1.6.0",
"enabled": true
}'