#!/bin/bash

# Ini merupakan script untuk mengunduh lagu dari playlist YT MUSic secara otomatis
# Script ini juga bakal dijalankan secara otomatis setiap bulan untuk melihat update lagu setiap playlist

# --- PENGATURAN ---
# Folder Musik Utama (Sesuai settingan CasaOS Anda)
MUSIC_DIR="/holder/hdd/Navidrome/Music"
DOCKER_MOUNT="/music"

# Fungsi untuk mendownload (JANGAN DIUBAH)
download_playlist() {
    local FOLDER_NAME="$1"
    local PLAYLIST_URL="$2"

    echo "--- Memproses Playlist: $FOLDER_NAME ---"
    
    # Perintah Docker yt-dlp dengan fitur Archive (Pencatat Riwayat)
    docker run --rm \
      -v "$MUSIC_DIR":"$DOCKER_MOUNT" \
      --user $(id -u):$(id -g) \
      jauderho/yt-dlp \
      "$PLAYLIST_URL" \
      -x --audio-format mp3 \
      --embed-thumbnail --add-metadata \
      --download-archive "$DOCKER_MOUNT/Playlists/$FOLDER_NAME/archive.txt" \
      --parse-metadata "playlist_index:%(track_number)s" \
      -o "$DOCKER_MOUNT/Playlists/$FOLDER_NAME/%(playlist_index)s - %(title)s.%(ext)s" \
      --ignore-errors
      
    # Jeda 10 detik agar YouTube tidak curiga (Anti-Banned)
    sleep 10
}

# --- DAFTAR PLAYLIST ANDA (EDIT DI SINI) ---
# Format: download_playlist "NAMA FOLDER" "LINK YOUTUBE"

download_playlist "Vocaloid Song" "https://www.youtube.com/playlist?list=PL8W6x5qy9apLt3O8wH-3QpmoV1WhRUaAX"
download_playlist "Lagu para wibu" "https://www.youtube.com/playlist?list=PL8W6x5qy9apLPW8UkvVYXQ41T7J4DXhUs"
download_playlist "Lagu wewew" "https://www.youtube.com/playlist?list=PL8W6x5qy9apJwAHfBvKNhWmCunmoNdqrA"
download_playlist "Favv 3" "https://www.youtube.com/playlist?list=PL8W6x5qy9apK-QWDlB6pjunWYjFcaYtSS"
download_playlist "RnM (FUCK HELL YEAH)" "https://www.youtube.com/playlist?list=PL8W6x5qy9apLcX5_9po5lM9IYt5jFsfa7"

# --- BAGIAN UPDATE FILE .M3U OTOMATIS ---
echo "--- Memperbarui File Playlist .m3u ---"
cd "$MUSIC_DIR/Playlists" && \
find . -maxdepth 1 -type d ! -path . -exec sh -c '
  nama_folder=$(basename "$1")
  cd "$1"
  # Hapus m3u lama biar fresh
  rm -f *.m3u
  # Buat m3u baru sesuai isi folder saat ini
  ls *.mp3 | sort -n > "${nama_folder}.m3u"
' _ {} \;

echo "--- SELESAI SEMUA ---"
