#!/bin/bash
API_KEY="YOUR_API_KEY"
DOMAIN_ID="9263073"
CACHE_FILE="$HOME/scripts/.last_ip"

CURRENT_IP=$(curl -s https://api.ipify.org)
LAST_IP=$(cat "$CACHE_FILE" 2>/dev/null)

if [ "$CURRENT_IP" != "$LAST_IP" ]; then
  echo "$(date): IP changed from $LAST_IP to $CURRENT_IP, updating..."

  CONFIG=$(curl -s -X GET "https://api.dynu.com/v2/dns/${DOMAIN_ID}" \
    -H "accept: application/json" \
    -H "API-Key: ${API_KEY}")

  UPDATED=$(echo "$CONFIG" | jq --arg ip "$CURRENT_IP" '.ipv4Address = $ip')

  curl -s -X POST "https://api.dynu.com/v2/dns/${DOMAIN_ID}" \
    -H "accept: application/json" \
    -H "API-Key: ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$UPDATED"

  echo "$CURRENT_IP" > "$CACHE_FILE"
else
  echo "$(date): IP unchanged ($CURRENT_IP), skipping update"
fi
