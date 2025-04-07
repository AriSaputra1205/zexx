#!/bin/bash

clear
IP=$(curl -s ipinfo.io/ip)
date=$(date +"%Y-%m-%d")
email=$(cat /home/email)
backup_dir="/root/backup"
zip_name="${IP}-${date}.zip"

# Siapkan folder backup
rm -rf "$backup_dir"
mkdir -p "$backup_dir"

# proses backup
cp /etc/passwd "$backup_dir/"
cp /etc/group "$backup_dir/"
cp /etc/shadow "$backup_dir/"
cp /etc/gshadow "$backup_dir/"
cp -r /etc/xray "$backup_dir/xray"
cp -r /root/nsdomain "$backup_dir/nsdomain"
cp -r /etc/slowdns "$backup_dir/slowdns"
cp -r /home/vps/public_html "$backup_dir/public_html"

# Buat ZIP
cd /root
zip -r "$zip_name" backup > /dev/null 2>&1

# Upload ke rclone (folder TUNNELING)
rclone copy "/root/$zip_name" "zexx:TUNNELING/"
url=$(rclone link "zexx:TUNNELING/$zip_name")
id=$(echo "$url" | cut -d'=' -f2)
link="https://drive.google.com/u/4/uc?id=${id}&export=download"

# Kirim email
message=$(cat <<EOF
Detail Backup
==================================
IP VPS        : $IP
Link Backup   : $link
Tanggal       : $date
==================================
EOF
)

echo "$message" | mail -s "Backup Data" "$email"

# Bersihkan
rm -rf "$backup_dir" "/root/$zip_name"

# Tampilkan ke terminal
clear
echo "$message"
echo "Silakan cek kotak masuk email: $email"
