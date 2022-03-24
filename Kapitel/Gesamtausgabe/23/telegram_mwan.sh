#!/bin/sh

# Nur Statusmeldungen berichten
if [[ "$ACTION" != "connected" && "$ACTION" != "disconnected" ]] ; then
  exit 0
fi

# Zugriff zur Telegram-API
API_KEY="869879271:AAUEMe8wjRxZ..."
CHAT_ID=123456789

# Nachrichtentext erstellen
MESSAGE="$HOSTNAME mwan3: $INTERFACE ($DEVICE) is $ACTION"

# Nachricht an Telegram senden
/usr/bin/wget --quiet -4 \
  --post-data="chat_id=$CHAT_ID&text=$MESSAGE" \
  https://api.telegram.org/bot$API_KEY/sendMessage

exit 0
