API=$(terraform output -raw api_endpoint)

curl -X PATCH \
"$API/cards/04c35898-6860-4b71-b4df-922ffb3a8e05" \
-H "Content-Type: application/json" \
-d '{
"user_id": "1",
"interval_increment": 3
}'

echo