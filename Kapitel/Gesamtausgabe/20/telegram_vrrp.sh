#!/bin/sh
 
logger -t keepalived.user "TYPE:$TYPE, NAME:$NAME, ACTION:$ACTION"

if [ "$TYPE" == "GROUP" ] ; then
  # Zugriff zur Telegram-API
  API_KEY="869879271:AAUEMe8wjRxZ..."
  CHAT_ID=123456789

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
  /usr/bin/wget --quiet -4 \
    --post-data="chat_id=$CHAT_ID&text=$MESSAGE" \
    https://api.telegram.org/bot$API_KEY/sendMessage
fi

exit 0
