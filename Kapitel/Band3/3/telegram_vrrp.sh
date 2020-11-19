#!/bin/sh
 
logger -t keepalived.user "TYPE:$TYPE, NAME:$NAME, ACTION:$ACTION"

if [ "$TYPE" == "GROUP" ] ; then
  # Ist das curl-Kommando installiert?
  which curl 1>/dev/null 2>&1 || {
    logger -t keepalived.user "Bitte curl-Paket installieren"
    exit 1
  }

  # Zugriff zur Telegram-API
  API_KEY="898796242:AAEUeM9WjxrBZ-oMtvbKX8mkJGs16L3mte8"
  CHAT_ID=273716448

  # Nachrichtentext erstellen
  MESSAGE="$HOSTNAME vrrp: Failover Gruppe $NAME"
  case "$ACTION" in
    NOTIFY_MASTER)
      MESSAGE="$MESSAGE nach MASTER"
      ;;
    NOTIFY_BACKUP)
      MESSAGE="$MESSAGE nach BACKUP"
      ;;
    *)
      exit 0
      ;;
  esac

  # Nachricht an Telegram senden
  logger -t keepalived.user "sending telegram message"
  /usr/bin/curl --silent --ipv4 \
    --data "chat_id=$CHAT_ID&text=$MESSAGE" \
    https://api.telegram.org/bot$API_KEY/sendMessage >/dev/null
fi

exit 0
