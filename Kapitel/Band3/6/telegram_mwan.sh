#!/bin/sh

# Ist das curl-Kommando installiert?
which curl 1>/dev/null 2>&1 || {                      
  logger -t mwan3alert "Bitte curl-Paket installieren"
  exit 1
}    

# Nur Statusmeldungen berichten
if [[ $ACTION != "connected" && $ACTION != "disconnected" ]] ; then
  exit 0
fi

# Zugriff zur Telegram-API
API_KEY="898796242:AAEUeM9WjxrBZ-oMtvbKX8mkJGs16L3mte8"
CHAT_ID=273716448

# Nachrichtentext erstellen
MESSAGE="$HOSTNAME mwan3: $INTERFACE ($DEVICE) is $ACTION"

# Nachricht an Telegram senden
/usr/bin/curl --silent --ipv4 \
  --data "chat_id=$CHAT_ID&text=$MESSAGE" \
  https://api.telegram.org/bot$API_KEY/sendMessage >/dev/null

exit 0
