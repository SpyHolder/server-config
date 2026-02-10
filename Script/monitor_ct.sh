#!/bin/bash

# Ini merupakan script untuk memberitahu container yang mati pada proxmox

# Konfigurasi token telegram
TOKEN="8296113567:AAEkP49kckIZetqFPI8Sk3whyTpgNCQCeRo"
CHAT_ID=" 970487432"

# Ambil daftar semua Container yang sedang "stopped"
STOPPED_CTS=$(pct list | awk '$2=="stopped" {print $1 " (" $3 ")" }')

if [ ! -z "$STOPPED_CTS" ]; then
    MESSAGE="🚫 *CONTAINER MATI TERDETEKSI*%0A%0A*Daftar CT:*%0A$STOPPED_CTS"
    
    # Kirim ke Telegram
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d "chat_id=$CHAT_ID&text=$MESSAGE&parse_mode=Markdown"
fi