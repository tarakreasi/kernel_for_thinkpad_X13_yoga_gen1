#!/bin/bash
# Script to debug why i915 driver might not be working properly

echo "==========================================="
echo "   DIAGNOSA DRIVER GRAFIS (i915)"
echo "==========================================="

echo -e "\n1. Cek status Secure Boot:"
if command -v mokutil &> /dev/null; then
    sudo mokutil --sb-state
else
    echo "mokutil tidak terinstall (kemungkinan Secure Boot aktif jika modul gagal load)"
fi

echo -e "\n2. Cek Modul i915 yang terpanggil:"
modinfo i915 | grep filename

echo -e "\n3. Cek Status Driver di Hardware:"
lspci -k -s 00:02.0

echo -e "\n4. Cek Error di Kernel Log (dmesg):"
sudo dmesg | grep i915 | grep -E "error|failed|rejected|unsigned|tainting" | tail -n 10

echo "==========================================="
echo "Jika 'Kernel driver in use: i915' TIDAK ADA di poin 3,"
echo "Atau ada error 'unsigned' / 'rejected' di poin 4,"
echo "Maka Secure Boot memblokir driver custom kita."
