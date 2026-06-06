API=$(terraform output -raw api_endpoint)

curl -X GET \
"$API/cards/1" \
-H "Content-Type: application/json"

echo