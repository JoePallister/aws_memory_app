API=$(terraform output -raw api_endpoint)

curl -X POST \
"$API/cards" \
-H "Content-Type: application/json" \
-d '{
"user_id": "12"
}'

echo