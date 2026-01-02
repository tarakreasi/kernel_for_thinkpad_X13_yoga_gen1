#!/bin/bash

# Pastikan script dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Harap jalankan script ini dengan sudo!"
  echo "Usage: sudo ./fix_lenovo.sh"
  exit 1
fi

echo "=== MEMULAI PERBAIKAN LENOVO THINKPAD X13 YOGA ==="
echo "[1/4] Mengamankan Kernel 5.15..."
# Kita tidak melakukan apa-apa disini karena install kernel baru TIDAK menghapus yang lama secara otomatis.
# Kernel 5.15 akan tetap ada di menu GRUB "Advanced Options".
echo "      Kernel lama Anda aman. Opsi boot akan bertambah, bukan berkurang."

echo "[2/4] Menginstall Kernel OEM (Optimized for Lenovo)..."
apt update
apt install -y linux-oem-24.04
if [ $? -ne 0 ]; then
    echo "Gagal menginstall kernel! Cek koneksi internet Anda."
    exit 1
fi

echo "[3/4] Mengkonfigurasi GRUB (Fix Flickering & Mic)..."
# Backup dulu
cp /etc/default/grub /etc/default/grub.bak.$(date +%F_%T)
echo "      Backup tersimpan di /etc/default/grub.bak..."

# Parameter baru:
# i915.enable_psr=0     -> Mencegah layat berkedip (Panel Self Refresh off)
# intel_iommu=igfx_off  -> Mencegah konflik memori grafik di kernel baru
# Kami MENGHAPUS 'intel_idle.max_cstate=1' agar baterai Anda awet kembali!
NEW_GRUB_CMD="GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash i915.enable_psr=0 intel_iommu=igfx_off\""

# Ganti baris di file
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/'"$NEW_GRUB_CMD"'/' /etc/default/grub

echo "[3.5/4] Fix Audio Flicker (Disable Power Save)..."
echo "options snd_hda_intel power_save=0 power_save_controller=N" > /etc/modprobe.d/audio_disable_powersave.conf
echo "      Config written to /etc/modprobe.d/audio_disable_powersave.conf"


echo "[4/4] Mengupdate Bootloader..."
update-grub

echo "========================================================"
echo "SELESAI! Silakan REBOOT laptop Anda."
echo "Saat booting, pilih 'Ubuntu' (otomatis masuk kernel baru)."
echo "Jika ada masalah, pilih 'Advanced options for Ubuntu' -> Pilih Kernel 5.15."
echo "========================================================"
