# Perjalanan Menjinakkan Layar Berkedip: Bagian 1 - Awal Mula

*Dipublikasikan: 2 Januari 2026*

Dalam dunia Linux, seringkali kita dihadapkan pada pilihan dilematis: bertahan dengan kernel versi lama yang stabil ("Long Term Support" atau LTS), atau beralih ke kernel terbaru yang menawarkan fitur terkini namun penuh kejutan. Selama ini, saya adalah pengguna setia **Kernel 5.15**.

## Mengapa Saya Meninggalkan Zona Nyaman 5.15?

Sebelumnya, dalam artikel "Why I Chose Kernel 5.15", saya menjelaskan panjang lebar keputusan pragmatis saya untuk bertahan di versi tersebut. Di Lenovo ThinkPad X13 Yoga saya, kernel 5.15 memberikan stabilitas yang tak tergantikan—"it just works". Tidak ada kedipan layar, manajemen daya yang solid, dan kompatibilitas hardware yang matang.

Namun, teknologi tidak pernah berhenti bergerak. Keinginan untuk mendapatkan efisiensi baterai yang lebih baik dan dukungan maksimal untuk ekosistem perangkat lunak di tahun 2026 mendorong saya untuk keluar dari zona nyaman. Saya memutuskan untuk menginstal **Kernel OEM 6.14**.

Harapannya sederhana: mendapatkan performa maksimal tanpa mengorbankan fungsi dasar. Namun, realitas seringkali berbeda dengan harapan.

## Masalah: Kedipan Layar yang Persisten

Segera setelah beralih ke kernel 6.14, saya "disambut" kembali oleh masalah lama yang dulu menjadi alasan utama saya bertahan di 5.15: **screen flickering** atau kedipan layar yang persisten.

Gejala yang muncul sangat spesifik dan konsisten, persis seperti mimpi buruk yang pernah saya alami sebelumnya:
1.  **Pola Waktu**: Kedipan tidak terjadi secara acak. Ia muncul setelah sistem berada dalam kondisi diam (*idle*) selama sekitar 1,5 hingga 2 detik.
2.  **Pemicu Interaksi**: Segera setelah ada input—menggerakkan kursor, mengetik, atau menyentuh layar—layar akan berkedip hebat.
3.  **Dampak Penggunaan**: Ini bukan sekadar gangguan visual minor. Kedipan "genit" seperti lampu neon rusak ini membuat laptop hampir mustahil digunakan untuk produktivitas jangka panjang tanpa menyebabkan sakit kepala.

Bagi sebuah mesin "daily driver", kondisi ini jelas tidak dapat diterima.

## Investigasi Awal dan Upaya Konvensional

Layaknya pengguna Linux yang menemui masalah grafis Intel, saya memulai diagnosa dengan langkah-langkah standar yang sudah menjadi "mantra" di berbagai forum komunitas.

### Percobaan 1: Parameter Kernel Standar

Tersangka utama kasus ini hampir selalu berkaitan dengan fitur hemat daya agresif dari driver Intel. Saya mencoba menerapkan solusi klasik melalui parameter GRUB:

```bash
i915.enable_psr=0        # Mematikan Panel Self Refresh
intel_iommu=igfx_off     # Mematikan IOMMU untuk grafis Intel
i915.enable_fbc=0        # Mematikan Frame Buffer Compression
intel_idle.max_cstate=4  # Membatasi C-states CPU
```

Secara teori, mematikan *Panel Self Refresh* (PSR) dan *Frame Buffer Compression* (FBC) adalah solusi de facto. Namun, pada kernel 6.14, dampaknya sangat minimal. Frekuensi kedipan mungkin berkurang sedikit, tetapi masalah utamanya tetap bercokol.

### Percobaan 2: Verifikasi Sistem

Tidak ingin hanya menebak-nebak, saya memverifikasi apakah parameter tersebut benar-benar diterapkan oleh sistem:

```bash
sudo cat /sys/module/i915/parameters/enable_psr # Output: 0
sudo cat /sys/module/i915/parameters/enable_fbc # Output: 0
```

Hasil verifikasi menunjukkan angka `0`—artinya fitur tersebut sudah dimatikan. Logikanya, jika fitur penyebab masalah sudah mati, layar seharusnya stabil. Fakta bahwa kedipan terus terjadi menunjukkan adanya perubahan fundamental pada cara kernel 6.14 menangani *power management* grafis Intel Comet Lake, yang berbeda drastis dari perilaku "adem ayem" di kernel 5.15.

## Titik Balik: Kesadaran Akan Kompleksitas

Di sinilah saya menyadari bahwa solusi level pengguna (user-space configuration) sudah tidak lagi memadai. Ada sesuatu yang berubah di balik layar—regresi atau perubahan arsitektur pada driver `i915` di kernel baru yang membuat konfigurasi standar tidak efektif.

Saya dihadapkan pada dua pilihan:
1.  **Mundur Teratur**: Kembali menginstal kernel 5.15 dan menikmati kestabilan tanpa fitur baru (opsi yang sangat menggoda).
2.  **Eskalasi Masalah**: Membedah kernel itu sendiri, memahami kode sumbernya, dan memaksanya bekerja sesuai keinginan saya.

Dengan semangat "kenapa harus mudah kalau bisa susah" (dan kebutuhan akan fitur baru), saya memilih opsi kedua. Saya menyimpulkan bahwa saya perlu melakukan tindakan yang lebih drastis daripada sekadar mengedit GRUB: **mengompilasi ulang modul kernel dengan parameter yang di-hardcode**.

Dalam bagian selanjutnya, saya akan mendokumentasikan langkah-langkah persiapan lingkungan build untuk melakukan "operasi bedah" pada kernel ini.

*(Bersambung ke Bagian 2)*

---
*Berani mengambil risiko kernel baru berarti siap dengan konsekuensi debugging di malam hari.*
