"""
Ini merupakan script untuk memantau/memonitoring penggunaan listrik untuk rumah 1300 VA
Script ini di jalankan setiap bulan dan akan memberikan harga KASAR dari penggunaan server selama 1 bulan kebelakang
Sebelum menjalankan script ini dijalankan, disarankan untuk membuat Local Environment Python
Lakukan juga "pip install requests"
"""


import csv
import requests
import os
from datetime import datetime, timedelta

# === KONFIGURASI ===
BOT_TOKEN = '7960322082:AAH3jdgduR4zDvgTxpCjdkhibr-4b2AgrdQ'
CHAT_ID = '970487432'
CSV_FILE = "/root/scripts/log_listrik.csv"

def send_telegram(pesan):
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
    payload = {"chat_id": CHAT_ID, "text": pesan, "parse_mode": "Markdown"}
    requests.post(url, json=payload)

def main():
    if not os.path.exists(CSV_FILE):
        return

    # Tentukan string bulan lalu (Format: YYYY-MM)
    hari_ini = datetime.now()
    bulan_lalu_obj = hari_ini.replace(day=1) - timedelta(days=1)
    target_bulan = bulan_lalu_obj.strftime("%Y-%m") # Contoh: "2023-10"
    nama_bulan_lalu = bulan_lalu_obj.strftime("%B %Y")

    total_biaya = 0
    total_kwh = 0
    hari_tercatat = 0

    with open(CSV_FILE, mode='r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # Cek apakah tanggal di baris ini milik bulan lalu?
            if row['tanggal'].startswith(target_bulan):
                total_biaya += float(row['biaya'])
                total_kwh += float(row['kwh'])
                hari_tercatat += 1

    if hari_tercatat == 0:
        pesan = f"📅 **Laporan Bulan {nama_bulan_lalu}**\nData kosong / Server mati total bulan lalu."
    else:
        pesan = (
            f"📊 **REKAP LISTRIK BULANAN**\n"
            f"🗓️ Periode: **{nama_bulan_lalu}**\n"
            f"--------------------------------\n"
            f"✅ Aktif: {hari_tercatat} Hari\n"
            f"🔋 Total Energi: {total_kwh:.2f} kWh\n"
            f"💰 **TOTALBIAYA: Rp {total_biaya:,.0f}**\n"
            f"--------------------------------\n"
            f"_Data tersimpan di CSV_"
        )
    
    print(pesan)
    send_telegram(pesan)

if __name__ == "__main__":
    main()