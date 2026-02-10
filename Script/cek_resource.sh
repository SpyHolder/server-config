#!/bin/bash

# Ini merupakan script untuk memberitahu kalau terdapat suhu CPU, penggunaan RAM dan CPU di luar batas wajar

#!/bin/bash

# --- KONFIGURASI TOKEN TELEGRAM ---
TOKEN="8296113567:AAEkP49kckIZetqFPI8Sk3whyTpgNCQCeRo"
CHAT_ID="970487432"

# Batas Bahaya (Ubah sesuai "kebiasaan" server kamu)
LIMIT_RAM=90
LIMIT_CPU=85
LIMIT_TEMP=80

# Waktu jeda antar pengecekan (detik)
CHECK_INTERVAL=5

# Status awal (jangan diubah)
IS_ALERT_SENT=false

echo "Monitoring dimulai... (Tekan Ctrl+C untuk berhenti)"

# "while true" artinya lakukan terus menerus tanpa henti
while true; do

    # --- 1. AMBIL DATA ---
    RAM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
    
    CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print int($1)}')
    CPU_USAGE=$((100 - CPU_IDLE))

    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp)
        TEMP_CPU=$((TEMP_RAW / 1000))
    else
        TEMP_CPU=0
    fi

    # --- 2. CEK KONDISI ---
    
    # Cek apakah ada yang melebihi batas?
    if [ "$RAM_USAGE" -gt "$LIMIT_RAM" ] || [ "$CPU_USAGE" -gt "$LIMIT_CPU" ] || [ "$TEMP_CPU" -gt "$LIMIT_TEMP" ]; then
        
        # JIKA bahaya DAN belum pernah kirim notifikasi sebelumnya
        if [ "$IS_ALERT_SENT" = false ]; then
            MESSAGE="⚠️ *WASPADA: LONJAKAN AKTIVITAS*%0A%0A"
            MESSAGE+="Server sedang bekerja keras!%0A"
            MESSAGE+="------------------------%0A"
            MESSAGE+="💾 *RAM:* ${RAM_USAGE}% (Batas: ${LIMIT_RAM}%)%0A"
            MESSAGE+="⚙️ *CPU:* ${CPU_USAGE}% (Batas: ${LIMIT_CPU}%)%0A"
            MESSAGE+="🔥 *Suhu:* ${TEMP_CPU}°C (Batas: ${LIMIT_TEMP}°C)"

            curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
                -d "chat_id=$CHAT_ID&text=$MESSAGE&parse_mode=Markdown" > /dev/null
            
            # Tandai bahwa pesan sudah dikirim, jadi tidak spam
            IS_ALERT_SENT=true
            echo "[$(date)] BAHAYA: Pesan terkirim."
        fi

    else
        # JIKA kondisi normal kembali
        if [ "$IS_ALERT_SENT" = true ]; then
            # Reset status agar jika nanti naik lagi, bisa kirim pesan lagi
            IS_ALERT_SENT=false
            echo "[$(date)] Kondisi kembali normal."
            
            # Opsional: Kirim pesan "Sudah Aman" ke Telegram (Hapus tanda # di bawah jika mau)
            # curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$CHAT_ID&text=✅ Server sudah kembali normal.&parse_mode=Markdown" > /dev/null
        fi
    fi

    # Istirahat sejenak sebelum cek lagi
    sleep $CHECK_INTERVAL

done