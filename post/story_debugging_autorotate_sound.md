# Kisah Debugging: Layar Blank Saat Rotasi & Misteri Suara

_Ditulis oleh T. Wantoro_

Rasanya kemenangan sudah di tangan. Kernel 6.14 OEM sudah terinstall, *screen flickering* yang menghantui selama ini sudah sembuh total berkat patch i915 manual. Laptop terasa smooth, performa kencang.

Saya pun dengan percaya diri melipat layar ThinkPad X13 Yoga ini menjadi mode tablet.

**Seketika, layar menjadi hitam.**

Hati saya mencelos. Apakah kernel panic? Apakah GPU crash lagi? Tapi keyboard backlight masih menyala. Saya coba `Alt+F2` dan ketik `r` (restart shell), tidak ada reaksi. Hard reset.

## Babak 1: Misteri Rotasi yang Mematikan

Setelah reboot, saya mencoba menganalisa. Masalah hanya muncul saat *fisik* laptop diputar/dilipat. Sensor accelerometer bekerja, mengirim sinyal ke OS, OS mencoba merotasi tampilan, dan... *blank*.

### Tersangka Utama: Budgie Desktop vs Kernel Baru
Di kernel 5.15 lama, rotasi berjalan agak lambat tapi aman. Di 6.14, nampaknya driver grafis baru (terutama dengan *fbc* dan *psr* yang kita mainkan) tidak bersahabat dengan cara compositing window manager (Mutter/Budgie) menangani rotasi instan.

Saya menggali log `journalctl`:
```text
mutter[...]: commons: monitor ... output assignment failed
```
Ternyata saat rotasi fisik terjadi, resolusi dan orientasi berubah mendadak, dan entah kenapa output video "terputus" sejenak yang menyebabkan *black screen* permanen di sesi user.

### Solusi: Skrip Penengah (`budgie_autorotate.sh`)
Alih-alih membiarkan OS merotasi secara "barbar", saya membuat script python/bash hybrid yang:
1. Membaca sensor monitor-sensor-proxy.
2. Secara *graceful* memerintahkan `xrandr` untuk merotasi layar.
3. Sekaligus merotasi input touchscreen dan stylus (Wacom) agar kursor tidak "nyasar".

Hasilnya? Rotasi kini mulus. Memang butuh 1 detik delay, tapi jauh lebih baik daripada harus hard reset setiap kali ingin membaca komik dalam mode potret.

## Babak 2: Verifikasi Suara (Sound & Mic)

Trauma dengan kernel 5.15 dimana microphone membutuhkan `snd_hda_intel dmic_detect=0` atau patch ribet, saya bersiap untuk perang lagi demi audio.

Saya buka *Sound Settings*. Output: **Speaker**. Input: **Microphone Array**.
Saya coba putar lagu di YouTube. Suara keluar jernih.
Saya coba rekam suara. Gelombang suara masuk.

Tunggu, **itu saja?**

Ternyata, Kernel 6.14 OEM membawa driver **Sound Open Firmware (SOF)** yang jauh lebih matang untuk chipset Intel Comet Lake (CNL) dibanding kernel lama. Di kernel 5.15, driver SOF sering crash atau gagal memuat topologi DSP. Di 6.14, "it just works".

Satu-satunya tweak kecil yang saya tambahkan adalah mematikan *audio power save* yang terlalu agresif, yang terkadang bikin suara "pop" saat speaker baru nyala:
```bash
options snd_hda_intel power_save=0 power_save_controller=N
```
Ini saya masukkan ke `fix_lenovo.sh` sekalian untuk memastikan pengalaman premium.

## Kesimpulan

Perjalanan migrasi ke Kernel 6.14 OEM ini mengajarkan satu hal: **Hardware baru butuh Software baru**.
Memaksakan kernel LTS (5.15) di hardware modern (relatif) seperti X13 Yoga ternyata lebih banyak *pain* daripada *gain*. Masalah rotasi hanyalah *hiccup* kecil konfigurasi desktop environment, bukan kernel panic. Dan bonusnya? Audio native tanpa hack!

ThinkPad X13 Yoga ini sekarang benar-benar "Selesai".
