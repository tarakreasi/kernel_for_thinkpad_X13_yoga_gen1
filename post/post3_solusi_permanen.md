# Perjalanan Menjinakkan Layar Berkedip: Bagian 3 - Solusi Permanen

*Dipublikasikan: 2 Januari 2026*

Ketika konfigurasi lunak tidak lagi mempan dan sistem menolak untuk "menurut", seorang *engineer* memiliki satu opsi pamungkas: **Ubah kodenya.**

Keputusan untuk melakukan *patching* dan kompilasi ulang modul kernel bukanlah langkah yang diambil ringan. Namun, demi mendapatkan kembali stabilitas layaknya di kernel 5.15 namun dengan fitur modern kernel 6.14, ini adalah harga yang pantas dibayar.

## Operasi Bedah Kode

Target operasi saya adalah driver Intel i915 di dalam pohon sumber kernel. Saya melakukan dua modifikasi bedah untuk mengatasi akar masalah yang ditemukan pada tahap diagnosa.

### 1. Membungkam SAGV Secara Paksa

Target Berkas: `drivers/gpu/drm/i915/display/intel_display_params.h`

Saya memodifikasi definisi parameter `enable_sagv` untuk mematikan fitur ini secara *hardcoded* pada level default driver.

```c
// Kode Asli:
param(bool, enable_sagv, true, 0600) \

// Kode Modifikasi:
param(bool, enable_sagv, false, 0600) \
```

Dengan perubahan ini, driver akan selalu menginisialisasi dengan SAGV non-aktif, mengeliminasi potensi gangguan sinyal dari fluktuasi voltase agen sistem.

### 2. Meluruskan Logika Firmware

Target Berkas: `drivers/gpu/drm/i915/display/intel_dmc.c`

Untuk memperbaiki "krisis identitas" pada kernel 6.14, saya menyisipkan logika kondisional baru. Tujuannya tegas: memaksa kernel untuk memuat firmware Cannon Lake (CNL) jika mendeteksi hardware Comet Lake (CML), alih-alih menyerah pada *fallback* Kaby Lake.

```c
// 1. Definisikan path firmware yang benar
#define CNL_DMC_PATH DMC_LEGACY_PATH(cnl, 1, 07)
MODULE_FIRMWARE(CNL_DMC_PATH);

// ... di dalam fungsi intel_dmc_init ...

} else if (IS_COMETLAKE(i915)) {
    // Override: Paksa load firmware CNL untuk Comet Lake
    fw_path = CNL_DMC_PATH;
    max_fw_size = KBL_DMC_MAX_FW_SIZE;
} else if (IS_KABYLAKE(i915) || ...
```

## Hasil: Stabilitas yang Kembali

Setelah proses kompilasi modul yang cukup memakan waktu (dan mengatasi beberapa kendala dependensi build), saya menginstal modul `i915` yang telah dimodifikasi (`custom`) dan melakukan *reboot*.

Momen pembuktian pun tiba.

1.  **Verifikasi Firmware**: Log sistem kini dengan bangga melaporkan: **"Finished loading DMC firmware i915/cnl_dmc_ver1_07.bin"**. Kernel akhirnya mengenali identitas hardware dengan benar.
2.  **Verifikasi Parameter**: Status SAGV terkonfirmasi **N (Mati)** secara default.
3.  **Uji Stabilitas**: Saya membiarkan laptop *idle*. 5 menit. 10 menit. Saya gerakkan kursor. Saya mengetik. 

**Hening. Stabil. Sempurna.**

Tidak ada lagi kedipan. Layar laptop kini setenang dan sestabil saat saya menggunakan kernel 5.15, tetapi dengan bonus performa dan efisiensi dari kernel 6.14. Sejauh ini, kernel OEM 6.14 dengan patch kustom ini berjalan dengan sangat baik.

## Kesimpulan

Perjalanan ini mengajarkan bahwa dalam ekosistem *open source* seperti Linux, kita tidak pernah benar-benar menemui jalan buntu. "Ketidakkompatibilitasan" seringkali hanyalah kode yang belum disesuaikan dengan kebutuhan spesifik kita.

Dengan sedikit keberanian untuk membedah dan memahami cara kerja sistem, kita bisa mendapatkan yang terbaik dari dua dunia: stabilitas masa lalu dan teknologi masa depan.

---
*Kernel OEM 6.14 Custom Build kini menjadi "daily driver" baru di ThinkPad X13 Yoga saya.*
