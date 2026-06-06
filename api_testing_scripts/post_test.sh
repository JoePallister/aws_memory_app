API=$(terraform output -raw api_endpoint)

curl -X POST \
"$API/cards" \
-H "Content-Type: application/json" \
-d '{
"user_id": "12",
"card_front": "What does 受 mean",
"card_back": "to receive"
}'

echo