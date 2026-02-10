"""
Ini merupakan script untuk memantau/memonitoring penggunaan listrik untuk rumah 1300 VA
Script ini di jalankan setiap hari dan akan memberikan harga KASAR dari penggunaan server 24 jam
Sebelum menjalankan script ini dijalankan, disarankan untuk membuat Local Environment Python
Lakukan juga "pip install requests"
"""


import csv
import os
import requests
from datetime import datetime

# === KONFIGURASI ===
BOT_TOKEN = '8249447843:AAFuX07pCvHDkhVZc-exhBjwxIiccWXcvY0'
CHAT_ID = '970487432'

# Tarif rumah 1300 VA
TARIF_PER_KWH = 1444.70

# File Input & Output
BUFFER_CSV = "/root/scripts/buffer_harian.csv"
HISTORY_CSV = "/root/scripts/log_listrik.csv" # Ini untuk akumulasi bulanan

def send_telegram(pesan):
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
    payload = {"chat_id": CHAT_ID, "text": pesan, "parse_mode": "Markdown"}
    requests.post(url, json=payload)

def main():
    if not os.path.exists(BUFFER_CSV):
        send_telegram("⚠️ Tidak ada data buffer listrik hari ini (Script pencatat mati?)")
        return

    # 1. Hitung Total kWh dari Buffer
    total_kwh_hari_ini = 0.0
    baris_data = 0
    
    with open(BUFFER_CSV, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            total_kwh_hari_ini += float(row['kwh_added'])
            baris_data += 1

    # 2. Hitung Biaya
    biaya_hari_ini = total_kwh_hari_ini * TARIF_PER_KWH
    
    # 3. Kirim Telegram
    pesan = (
        f"⚡ **Laporan Listrik Harian (REAL)**\n"
        f"📅 {datetime.now().strftime('%d-%m-%Y')}\n"
        f"--------------------------------\n"
        f"⏱️ Jumlah Sampel: {baris_data} x (interval cron)\n"
        f"🔋 Total Pakai: {total_kwh_hari_ini:.4f} kWh\n"
        f"💰 **Tagihan: Rp {biaya_hari_ini:,.0f}**"
    )
    print(pesan)
    send_telegram(pesan)
    
    # 4. Arsipkan ke History (Untuk hitungan bulanan nanti)
    # Kita simpan totalnya saja, bukan pecahannya
    file_exists = os.path.exists(HISTORY_CSV)
    header = ['tanggal', 'kwh', 'biaya']
    
    with open(HISTORY_CSV, 'a', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=header)
        if not file_exists:
            writer.writeheader()

        writer.writerow({
            'tanggal': datetime.now().strftime("%Y-%m-%d"),
            'kwh': f"{total_kwh_hari_ini:.4f}",
            'biaya': f"{biaya_hari_ini:.0f}"
        })

    # 5. Hapus/Reset Buffer (Siap untuk besok)
    os.remove(BUFFER_CSV)
    print("Buffer telah direset.")

if __name__ == "__main__":
    main()
