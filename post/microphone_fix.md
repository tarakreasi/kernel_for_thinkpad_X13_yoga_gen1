# Microphone Fix for Lenovo ThinkPad X13 Yoga - Kernel 5.15

## Problem
Microphone tidak terdeteksi di kernel 5.15 karena SOF (Sound Open Firmware) topology file dalam format compressed (.zst) sedangkan kernel mencari file uncompressed (.tplg).

## Symptoms
- `arecord -l` tidak menampilkan capture devices
- PulseAudio/PipeWire hanya mendeteksi dummy output
- Error di dmesg: `Direct firmware load for intel/sof-tplg/sof-hda-generic-2ch.tplg failed with error -2`

## Hardware Info
- **Audio Controller**: Intel Corporation Comet Lake PCH-LP cAVS
- **Microphones**: 2x Digital Microphones (DMIC)
- **Audio Driver**: SOF (Sound Open Firmware)

## Solution

### Manual Fix
```bash
# Decompress topology file
sudo zstd -d /lib/firmware/intel/sof-tplg/sof-hda-generic-2ch.tplg.zst \
    -o /lib/firmware/intel/sof-tplg/sof-hda-generic-2ch.tplg

# Reload audio driver
sudo modprobe -r snd_sof_pci_intel_cnl
sudo modprobe snd_sof_pci_intel_cnl

# Verify
arecord -l
```

### Automated Fix
Jalankan script yang sudah dibuat:
```bash
./fix_microphone.sh
```

## Verification
Setelah fix diterapkan, Anda akan mendapatkan:
- **Headphones Stereo Microphone**: untuk mic eksternal/headset
- **Digital Microphone**: mic internal laptop (2 channel)

Test recording:
```bash
arecord -d 3 -f cd test.wav
aplay test.wav
```

## Permanent Solution
Fix ini perlu dijalankan ulang setelah update firmware. Untuk membuat permanent:

1. **Buat systemd service** (opsional):
```bash
sudo nano /etc/systemd/system/sof-topology-fix.service
```

Content:
```ini
[Unit]
Description=SOF Topology Fix for Microphone
After=sound.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'zstd -d /lib/firmware/intel/sof-tplg/sof-hda-generic-2ch.tplg.zst -o /lib/firmware/intel/sof-tplg/sof-hda-generic-2ch.tplg 2>/dev/null || true'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable service:
```bash
sudo systemctl enable sof-topology-fix.service
sudo systemctl start sof-topology-fix.service
```

## References
- [SOF Project](https://github.com/thesofproject/sof-bin/)
- Kernel Module: `snd_sof_pci_intel_cnl`
- Firmware Package: `firmware-sof-signed`

## Date Fixed
2026-01-02
