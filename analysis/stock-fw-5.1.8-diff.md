# Stock firmware 5.1.8: exact diff vs 5.1.7 (Pro, unlisted)

Adventurer 5M **Pro** `Adventurer5MPro-5.1.8-2.2.3-20260630.tgz` sits on
FlashForge's official OSS bucket but is **not** linked from the [Pro download
page](https://www.flashforge.com/blogs/download-document/adventurer-5m-pro)
and is **not** offered by live OTA. Probed 2026-09-11:
`update.voxelshare.com` still advertises **v5.1.7** to a 5.1.4 printer, and
returns `Latest release version not found` for both 5.1.7 and 5.1.8.

Treat this as a real artifact (sha256-pinned below), not as the OTA-current
Pro release. The OTA-current Pro build is still 5.1.7
([`stock-fw-5.1.7-diff.md`](stock-fw-5.1.7-diff.md)).

## Provenance

| field | value |
|---|---|
| artifact | `Adventurer5MPro-5.1.8-2.2.3-20260630.tgz` |
| date in filename | 2026-06-30 (25 days after 5.1.7) |
| size / sha256 | 68403200 B · `7eaa49bfa2bd98cbe48b1f01f0bae010618bd8573bf8ecf533eab272b437b70a` |
| source | `https://flashforge-resource.oss-us-east-1.aliyuncs.com/AD5MP%E5%9B%BA%E4%BB%B6/Adventurer5MPro-5.1.8-2.2.3-20260630.tgz` (HEAD 200; not on the download page) |
| listed on official Pro page | no |
| advertised by OTA `app_id=35` | no |

No Pro 5.1.9 / 5.2.0 object exists at the usual `Adventurer5MPro-<ver>-2.2.3-<date>.tgz` names (HEAD-probed 2026-09-11).

## Exact file inventory vs 5.1.7 (58 files each)

Prefix-stripped comparison of extracted trees. 53 identical, 5 changed, 0 added,
0 removed. Of the five "changes", three are `md5sum.list` **line-order** only
(same MD5s, different sort). Real payload change: `firmwareExe`.

| path | 5.1.7 | 5.1.8 |
|---|---|---|
| `software/firmwareExe` | 9 564 802 B · sha256 `2765a1d432118269…102e` · BuildID `c4a4482f…0ba1` | 9 670 890 B · sha256 `26a938f293222925…514a` · BuildID `61200563…e03f` · **+106 088 B** |
| `software/md5sum.list` | 1302 B, `firmwareExe` MD5 `1b685cc6…` | 1302 B, `firmwareExe` MD5 `6148a678…` (other lines identical, reordered) |
| `kernel-2.1.6/md5sum.list` | same 8 MD5s | same 8 MD5s, reordered |
| `control-2.2.3/md5sum.list` | same 7 MD5s | same 7 MD5s, reordered |
| `library-2.5.0/md5sum.list` | same 6 MD5s | same 6 MD5s, reordered |

Byte-identical across 5.1.7 → 5.1.8 (and across 5M 5.1.7 / 5.1.9): `uImage`
(5 195 072 B), `sunxi.dtb`, `8821cu.ko`, `Mainboard-20230831.bin`,
`Eboard-20231012.hex`, `mcu.img`, `nim.tar`, `ffstartup-arm`,
`flashforge_init.sh`, `run.sh`, `ntpclient`, `client/*`, splash images,
`mencoder`, `play`.

## `firmwareExe` behavior delta (strings)

Rebuild on a new toolchain prefix (`/opt/gcc-linaro-…` →
`/opt/ad5dm-env/gcc-linaro-…`). Not-stripped, so most of the +106 KB is debug
info + a timelapse encoder switch.

- **Timelapse encode:** still ships the `mencoder` binary in the outer
  package, but the UI command string moves from `/opt/mencoder mf://` to
  `/opt/ffmpeg-4.0.2/bin/ffmpeg -y -f image2 -framerate 15 -i`. No ffmpeg
  binary is in the OTA tarball; if `/opt/ffmpeg-4.0.2` is not already on the
  rootfs this path is a no-op / fail at runtime. Not verified on device.
- **Legacy OTA URLs dropped** from the binary:
  `https://update.sz3dp.com:10443`, `https://update.cn.sz3dp.com:10443`.
  v2 VoxelShare OTA (`https://update.voxelshare.com/api/updates/check` and
  `…/v2/download_url`) remains. The plaintext-HTTP dev server
  `http://10.33.11.172:32112` is still compiled in.
- **Host set otherwise unchanged.** `polar3d.com` / `printer2.polar3d.com` /
  `api.voxelshare.com` / `api.fdmcloud.flashforge.com` were already in 5.1.7;
  5.1.8 just emits an extra bare `https://update.voxelshare.com` and
  `https://polar3d.com` string. No new hostname.
- Source-path strings moved `app/OssLogUploader.cpp` →
  `../source/app/OssLogUploader.cpp` (same for `powerSavingModeFile.cpp`,
  `resumeDialog.cpp`): build-directory shuffle, not a new feature.

## ReForge impact

- **cloudblock:** no new hosts. Dropping the sz3dp OTA URLs from the binary
  does not require removing them from the block list (older 5.x still has
  them).
- **kernel / MCU / library:** still the frozen 2.1.6 / 2.2.3 / 2.5.0
  payloads. Byte-identical kernel work stays valid.
- **USB `.tgz` install:** `flashforge_init.sh` unchanged from 5.1.4/5.1.7.
- **ffmpeg path:** if a unit on 5.1.8 actually calls ffmpeg for timelapse,
  stock does not ship that binary in this package. Untested.

## Reproduce

```sh
A=blobs/stock
../fetch-all-firmware.sh    # 5.1.8 is in firmware-sources.tsv
mkdir -p /tmp/fw517 /tmp/fw518
tar -xf "$A/Adventurer5MPro-5.1.7.tgz" -C /tmp/fw517
tar -xf "$A/Adventurer5MPro-5.1.8.tgz" -C /tmp/fw518
tar -xf /tmp/fw517/software-5.1.7.tar.xz -C /tmp/fw517
tar -xf /tmp/fw518/software-5.1.8.tar.xz -C /tmp/fw518
cmp /tmp/fw517/firmwareExe /tmp/fw518/firmwareExe   # differs
```
