#!/bin/sh

# Zugriff zur Telegram-API
API_KEY="869879271:AAUEMe8wjRxZ..."
CHAT_ID=123456789

while read LINE; do
  # Nachricht an Telegram senden
  /usr/bin/curl --silent --ipv4 \
    --data "chat_id=$CHAT_ID&text=$LINE" \
    https://api.telegram.org/bot$API_KEY/sendMessage >/dev/null
done

exit 0
