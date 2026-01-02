# Perjalanan Menjinakkan Layar Berkedip: Bagian 2 - Diagnosa Mendalam

*Dipublikasikan: 2 Januari 2026*

Setelah upaya mitigasi standar melalui parameter kernel gagal memberikan hasil yang memuaskan, saya menyadari bahwa masalah ini menuntut investigasi yang lebih serius. Pendekatan *trial-and-error* harus diganti dengan analisis forensik. Pertanyaan kuncinya: **Apa perbedaan fundamental antara kernel 5.15 (stabil) dan kernel 6.14 (bermasalah) pada perangkat keras spesifik ini?**

Saya memutuskan untuk menyelam ke dalam log sistem dan kode sumber kernel untuk mencari jawabannya.

## Temuan 1: Identitas yang Tertukar (Firmware Mismatch)

Langkah pertama adalah membandingkan log inisialisasi kernel (`dmesg`) dari kedua versi. Perbedaan kritis langsung terlihat pada bagaimana driver grafis mengenali dan memuat firmware *Display Microcontroller* (DMC).

Laptop ThinkPad X13 Yoga ini ditenagai oleh prosesor **Intel Comet Lake (CML)**.

*   **Pada Kernel 5.15**: Driver dengan tepat memuat firmware **Cannon Lake (CNL)**: `cnl_dmc_ver1_07.bin`, yang kompatibel dengan arsitektur grafis laptop ini.
*   **Pada Kernel 6.14**: Terjadi regresi. Driver secara keliru mengidentifikasi grafis sebagai **Kaby Lake (KBL)** dan memuat firmware lawas `kbl_dmc_ver1_04.bin`.

Ini adalah temuan signifikan. Kernel 6.14 mengalami "krisis identitas", memperlakukan prosesor Comet Lake modern sebagai varian Kaby Lake yang lebih tua, sehingga memuat instruksi mikrokontroler yang tidak optimal.

## Temuan 2: SAGV yang "Terlalu Rajin"

Selain ketidakcocokan firmware, saya memeriksa mekanisme manajemen daya tingkat lanjut yang sering terabaikan: **SAGV (System Agent Geyserville)**. Fitur ini memungkinkan sistem mengatur frekuensi dan voltase *System Agent* (termasuk kontroler memori) secara dinamis beban kerja.

Pemeriksaan status di kernel 6.14 menunjukkan:

```bash
sudo cat /sys/module/i915/parameters/enable_sagv
# Output: Y (Yes/True)
```

Di berbagai literatur teknis dan diskusi pengembang kernel Intel, SAGV kerap diidentifikasi sebagai sumber ketidakstabilan tampilan pada grafis terintegrasi Gen9.5. Perubahan voltase yang agresif saat sistem *idle* dapat mengganggu sinyal ke panel layar, menyebabkan kedipan persis seperti yang saya alami.

## Hipotesis Kerja

Berdasarkan data tersebut, saya merumuskan dua hipotesis utama penyebab masalah:

1.  **Firmware Salah Kamar**: Penggunaan firmware DMC Kaby Lake pada hardware Comet Lake menyebabkan manajemen daya display tidak sinkron.
2.  **Agresivitas SAGV**: Fitur penghematan daya memori ini terlalu agresif untuk toleransi panel layar laptop ini, menyebabkan instabilitas sinyal saat *idle*.

Masalahnya, mengubah parameter `enable_sagv` dan jalur firmware `dmc_firmware_path` seringkali tidak efektif jika hanya dilakukan via GRUB (user-space). Driver `i915` memiliki logika inisialisasi internal yang kerap mengabaikan parameter eksternal untuk konfigurasi vital seperti ini.

Jika "cara halus" (konfigurasi) tidak diindahkan oleh kernel, maka saya harus menempuh "cara keras": **memodifikasi logika driver itu sendiri.**

*(Bersambung ke Bagian 3)*
