Mengatasi Masalah Screen Flickering pada Lenovo ThinkPad X13 Yoga di Lingkungan Linux
Oleh: [Nama Penulis]

Lenovo ThinkPad X13 Yoga adalah perangkat yang luar biasa dengan build quality tangguh dan fleksibilitas tinggi. Namun, bagi pengguna Linux (khususnya berbasis Ubuntu/Debian), ada satu kendala teknis yang cukup sering ditemui: layar berkedip (screen flicker) setelah beberapa saat idle atau saat ada interaksi pada layar.

Artikel ini mendokumentasikan langkah-langkah troubleshooting yang telah saya lakukan untuk mengatasi masalah tersebut. Tujuannya adalah berbagi solusi teknis yang efektif tanpa mengorbankan efisiensi daya laptop secara signifikan. Semoga catatan ini dapat membantu rekan-rekan yang mengalami kendala serupa.

Analisis Masalah
Berdasarkan penelusuran, akar masalah utamanya terletak pada interaksi antara driver grafis Intel Linux dengan fitur hemat daya panel laptop, yaitu Panel Self Refresh (PSR).

Singkatnya, PSR memungkinkan GPU untuk masuk ke mode hemat daya saat gambar di layar statis. Sayangnya, pada beberapa konfigurasi panel di ThinkPad X13 Yoga, transisi saat GPU aktif kembali inilah yang menyebabkan gangguan visual atau glitch. Selain itu, manajemen memori IOMMU juga turut berkontribusi pada ketidakstabilan ini.

Solusi Teknis
Alih-alih mematikan seluruh fitur hemat daya CPU (seperti intel_idle.max_cstate=1) yang dapat menyebabkan laptop panas dan boros baterai, pendekatan yang saya sarankan lebih terfokus pada parameter spesifik yang bermasalah.

Berikut adalah langkah-langkah perbaikannya:

1. Pembaruan Kernel ke Versi OEM
Untuk memastikan kompatibilitas hardware terbaik, sangat disarankan menggunakan Kernel OEM. Kernel ini telah dioptimalkan oleh manufaktur untuk perangkat keras laptop terkini.

Di terminal Ubuntu/Linux Mint, jalankan perintah berikut:

sudo apt update
sudo apt install linux-oem-24.04
(Sesuaikan versi 24.04 dengan rilis LTS yang Anda gunakan)

2. Konfigurasi Parameter GRUB
Ini adalah langkah krusial. Kita perlu menonaktifkan fitur PSR dan menyesuaikan IOMMU melalui parameter boot kernel.

Sunting file konfigurasi GRUB:

sudo nano /etc/default/grub
Cari baris GRUB_CMDLINE_LINUX_DEFAULT. Tambahkan parameter berikut: i915.enable_psr=0 dan intel_iommu=igfx_off.

Sehingga baris tersebut terlihat seperti ini:

GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i915.enable_psr=0 intel_iommu=igfx_off"
Penjelasan Parameter:

i915.enable_psr=0: Menonaktifkan Panel Self Refresh untuk mencegah kedipan layar.
intel_iommu=igfx_off: Menonaktifkan IOMMU khusus untuk grafis terintegrasi guna menghindari konflik memori.
Simpan perubahan dan perbarui bootloader:

sudo update-grub
3. Optimalisasi Audio (Opsional)
Jika Anda juga mengalami gangguan suara "popping" atau kresek, ini biasanya disebabkan oleh fitur power saving pada sound card.

Anda dapat menonaktifkannya dengan membuat konfigurasi ini:

echo "options snd_hda_intel power_save=0 power_save_controller=N" | sudo tee /etc/modprobe.d/audio_disable_powersave.conf
Troubleshooting Lanjutan (Plan B)
Jika layar masih mengalami flickering setelah langkah di atas, ada kemungkinan fitur hemat daya lain yang menjadi penyebabnya. Lakukan langkah berikut:

Matikan Frame Buffer Compression & Batasi C-State
Tambahkan parameter i915.enable_fbc=0 dan intel_idle.max_cstate=4 ke GRUB.

i915.enable_fbc=0: Mematikan kompresi buffer frame yang terkadang menyebabkan artifak visual.
intel_idle.max_cstate=4: Membatasi sleep state prosesor agar tidak terlalu "lelap" (Deep Sleep), yang seringkali menyebabkan lag saat layar harus menyala kembali. Nilai 4 adalah jalan tengah yang lebih hemat daya daripada mematikan total (nilai 1).
Baris konfigurasi GRUB Anda akan terlihat seperti ini:

GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i915.enable_psr=0 intel_iommu=igfx_off i915.enable_fbc=0 intel_idle.max_cstate=4"
Jangan lupa jalankan sudo update-grub dan restart setelah perubahan.

Kesimpulan
Setelah menerapkan langkah-langkah di atas dan melakukan restart system, masalah layar berkedip pada ThinkPad X13 Yoga dapat teratasi sepenuhnya. Keuntungan utama dari metode ini adalah sistem tetap stabil dan efisiensi baterai tetap terjaga dengan baik, karena fitur hemat daya prosesor (C-States) tetap berfungsi normal.

Semoga panduan singkat ini bermanfaat bagi komunitas pengguna ThinkPad dan Linux. Selamat berkarya.