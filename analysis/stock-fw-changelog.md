# Stock firmware changelog: every downloadable AD5M / AD5M Pro release

A self-maintained, **artifact-grounded** changelog of FlashForge Adventurer 5M /
5M Pro stock firmware. Unlike FlashForge's marketing release notes (which only
describe UI features), this tracks the **component versions and content** of
every firmware package we can download: the layer ReForge actually cares about
(kernel, Wi-Fi driver, MCU firmware, cloud SDK, partition layout).

- **Manifest (URLs and checksums):** [`../firmware-manifest.tsv`](../firmware-manifest.tsv)
  (sha256 + size + component fingerprint for all 26 archived packages).
- **Re-fetch:** `../fetch-all-firmware.sh` (downloads → `blobs/stock/`,
  gitignored; re-verifies + re-fingerprints idempotently).
- Deep diffs:
  - [`stock-fw-5.1.7-diff.md`](stock-fw-5.1.7-diff.md): Pro 5.1.4 → 5.1.7 (OTA-current Pro)
  - [`stock-fw-5.1.8-diff.md`](stock-fw-5.1.8-diff.md): Pro 5.1.7 → 5.1.8 (unlisted OSS)
  - [`stock-fw-5.1.9-diff.md`](stock-fw-5.1.9-diff.md): 5M 5.1.7 → 5.1.9 (current 5M)

Every FF firmware package is a **plain tar** (despite `.tgz`/`.tar.xz`/`.rar`
names); the 2.x releases ship as a `.zip` (a few nest the tar one folder deep).
Each package contains four versioned component tarballs (`software-<v>` Qt UI
`firmwareExe`, `kernel-<v>`, `library-<v>` NetEase IM cloud SDK + `ffstartup`,
`control-<v>` the two N32G455 MCU firmwares) plus boot/splash images and the
installer. **Klipper is not in any package** (it lives on the eMMC `/data`
rootfs), which is why stock OTAs never touch the mod.

## Current as of 2026-09-11

| model | OTA / download-page current | newest OSS object | notes |
|---|---|---|---|
| 5M Pro | **5.1.7** (2026-06-05) | **5.1.8** (2026-06-30, unlisted) | live `update.voxelshare.com` still offers v5.1.7; 5.1.8 is on OSS but not linked and not advertised |
| 5M | **5.1.9** (2026-08-28) | 5.1.9 | on the official 5M download page; no 5.1.8 for 5M; no Pro 5.1.9 |

## Component-version timeline (Adventurer 5M Pro)

| Stock ver | Date | software | kernel | library | control (MCU) | sha256 (head) |
|---|---|---|---|---|---|---|
| 2.3.1 | 2023-09-21 | 2.3.1 | 2.1.4 | 2.1.0 | 2.1.8 | `67459bd4ecb2ca86` |
| 2.3.7 | 2023-11-10 | 2.3.7 | 2.1.4 | 2.1.0 | 2.1.9 | `11abaea23dbb7c31` |
| 2.4.5 | 2024-01-18 | 2.4.5 | 2.1.4 | 2.1.0 | **2.2.3** | `77ad2af67c89e1a7` |
| 3.1.3 | 2025-01-07 | 3.1.3 | **2.1.6** | **2.3.0** | 2.2.3 | `f0f578c62728a823` |
| 3.1.4 | 2025-01-16 | 3.1.4 | 2.1.6 | 2.3.0 | 2.2.3 | `9ca5c88d42af21bd` |
| 3.1.5 | 2025-02-12 | 3.1.5 | 2.1.6 | 2.3.0 | 2.2.3 | `b0ef201c156786bf` |
| 3.2.3 | 2025-10-17 | 3.2.3 | 2.1.6 | 2.3.0 | 2.2.3 | `f6182f4a0f986e05` |
| 3.2.4 | 2025-11-14 | 3.2.4 | 2.1.6 | 2.3.0 | 2.2.3 | `6d33ba91c0a68eb0` |
| 3.2.5 | 2025-11-26 | 3.2.5 | 2.1.6 | **2.5.0** | 2.2.3 | `3bf50c8ca2f5a58f` |
| 3.2.7 | 2025-12-17 | 3.2.7 | 2.1.6 | 2.5.0 | 2.2.3 | `f899ebf09d5f31b5` |
| 5.0.3 | 2026-01-22 | 5.0.3 | 2.1.6 | 2.5.0 | 2.2.3 | `babeccc0f3002762` |
| 5.1.2 | 2026-04-18 | 5.1.2 | 2.1.6 | 2.5.0 | 2.2.3 | `355be24caa28486d` |
| 5.1.4 | 2026-05-15 | 5.1.4 | 2.1.6 | 2.5.0 | 2.2.3 | `80e98c82b028c2c1` |
| 5.1.7 | 2026-06-05 | 5.1.7 | 2.1.6 | 2.5.0 | 2.2.3 | `58076910fe0a659f` |
| 5.1.8 | 2026-06-30 | 5.1.8 | 2.1.6 | 2.5.0 | 2.2.3 | `7eaa49bfa2bd98cb` |

## Component-version timeline (Adventurer 5M, 5.x)

| Stock ver | Date | software | kernel | library | control (MCU) | sha256 (head) |
|---|---|---|---|---|---|---|
| 5.0.3 | 2026-01-22 | 5.0.3 | 2.1.6 | 2.5.0 | 2.2.3 | `dab1ede20bd6e689` |
| 5.1.1 | 2026-04-17 | 5.1.1 | 2.1.6 | 2.5.0 | 2.2.3 | `8a8a026eaa15fe78` |
| 5.1.4 | 2026-05-15 | 5.1.4 | 2.1.6 | 2.5.0 | 2.2.3 | `998df12f46f2c323` |
| 5.1.7 | 2026-06-05 | 5.1.7 | 2.1.6 | 2.5.0 | 2.2.3 | `c0de8b3989ab24fb` |
| 5.1.9 | 2026-08-28 | 5.1.9 | 2.1.6 | 2.5.0 | 2.2.3 | `55257c0def0ce14d` |

(Earlier 5M 3.x rows are in the manifest. Same kernel/control track as Pro;
library followed 2.3.0 → 2.4.0 at 5M-3.1.9 → 2.5.0 at 5M-3.2.5.)

## What actually changes, and when

Only **three transitions** in the whole 2.3 → 5.1 range touch anything below the
UI app. Everything else is `firmwareExe` (and the cloud SDK) churn.

- **MCU firmware (`control`):** `2.1.8` → `2.1.9` (2.3.7) → **`2.2.3` (2.4.5,
  Jan 2024) and frozen ever since.** The two N32G455 blobs (`Mainboard-20230831.bin`,
  `Eboard-20231012.hex`) are byte-identical from 2.4.5 through Pro 5.1.8 / 5M 5.1.9.
- **Kernel:** `2.1.4` → **`2.1.6` (3.1.3, Jan 2025) and frozen ever since.**
  `uImage` (Linux 5.4.61), `sunxi.dtb` and `8821cu.ko` (the RTL8821CU Wi-Fi
  driver) are byte-identical from 3.1.3 through Pro 5.1.8 / 5M 5.1.9.
- **library** (NetEase IM cloud SDK `nim.tar` + `ffstartup-arm`): `2.1.0` →
  `2.3.0` (3.1.3) → **`2.5.0` (3.2.5, Nov 2025).** Stable across all 5.x. This is
  the only non-UI component that moved inside the 3.x/5.x range.

So a printer on **any** 3.1.3 – 5.1.9 build runs the **same kernel, Wi-Fi driver,
MCU firmware and partition layout**. The stock-version number almost entirely
tracks the Qt UI app.

Component wrapper tarballs (`kernel-2.1.6.tar.xz` etc.) often have different
sha256 across releases even when every extracted file is identical: the inner
`md5sum.list` is sometimes reordered, and the tar itself is not reproducible.
Trust the extracted-file hashes, not the wrapper hash.

### `firmwareExe` / cloud-surface highlights

- **2.x → 3.x:** kernel + MCU bump (above); UI feature work (Orca-Flashforge, LAN
  mode, exclude-objects, PID calibration; see FF's notes, linked below).
- **5.0.x (Jan 2026):** the **"Flash Studio" cloud** lands in `firmwareExe`: an
  Eclipse Paho **MQTT** client (`api.fdmcloud.flashforge.com` broker bootstrap),
  **VoxelShare** model sharing, stock OTA, and the **NetEase IM (Yunxin)**
  messaging backbone (`*.netease.im`, `*.127.net`). This is the full telemetry/
  cloud surface the ReForge `cloudblock` (`S00cloudblock`, in the reforge repo)
  pins to `127.0.0.1`.
- **5.1.4 (May 2026):** cloud hosts **reshuffled**. OTA moved
  `update.flashforge.com` → `update.voxelshare.com`, live video → `liveplay` /
  `livepush.flashforge.com`; and a standalone **`ntpclient`** was added (SNTP to
  `pool.ntp.org`). The cloudblock host set was updated for this.
- **5.1.7 (Jun 2026, OTA-current Pro):** `firmwareExe`-only +354-byte rebuild.
  Official OTA notes: Flash Studio offline reconnect, grayed "My Account" when
  offline, power-loss resume fix, offline page lag. No new endpoints. Full
  file-level breakdown in [`stock-fw-5.1.7-diff.md`](stock-fw-5.1.7-diff.md).
- **5.1.8 (Jun 2026, Pro, unlisted OSS):** `firmwareExe` +106 KB. Timelapse
  command string switches to `/opt/ffmpeg-4.0.2` (binary not in the package).
  Legacy `update.sz3dp.com:10443` OTA URLs dropped from the binary. No new
  hosts. Not advertised by OTA. [`stock-fw-5.1.8-diff.md`](stock-fw-5.1.8-diff.md).
- **5.1.9 (Aug 2026, 5M current):** `firmwareExe` +206 KB plus new
  `software/config/server.json` (VoxelShare `appUrl` + fdmcloud `healthxUrl`,
  both already hardcoded). **New host: `ipinfo.io`** (`https://ipinfo.io/country`).
  MQTT connect moved to a background thread. Same ffmpeg command-string switch
  as Pro 5.1.8. [`stock-fw-5.1.9-diff.md`](stock-fw-5.1.9-diff.md).

### Official UI release notes

FlashForge's per-version feature notes (touchscreen UI changes) are not mirrored
here; they are at the FF [firmware update log](https://www.flashforge.com/a/docs/adventurer-5m-series/adventurer-5m-series-firmware-update-log)
(2.x) and the [release-history wiki](https://wiki.flashforge.com/en/adventurer-series/manual/firmware-release-history)
(3.x; wiki is stale past 3.1.9). The 2.x `.zip` packages also embed an
`*_update log.txt` per release. The 5.1.7 OTA changelist is captured in the
5.1.7 diff (queried live from `update.voxelshare.com`). They describe UI/print
behavior; none of it changes the component layer above.

## ReForge relevance

- **cloudblock host set** covers the 5.0.x cloud surface + the 5.1.4 reshuffle
  through Pro 5.1.8. `pool.ntp.org` is a real stock endpoint we intentionally
  leave unblocked (benign NTP). **Gap: `ipinfo.io`**, new in 5M 5.1.9
  `firmwareExe`, is not in `S00cloudblock`.
- **Kernel work** (byte-identical stock-kernel build, module packaging) holds for
  every 3.1.3 – 5.1.9 unit: same `uImage`/`dtb`/`8821cu.ko`.
- **MCU update path** targets the frozen `control-2.2.3` (Klipper 11).
- **Install hooks / dual-boot:** `flashforge_init.sh` + partition layout are
  stable per model, so ReForge's `.tgz` install and stock dual-boot work across
  the range.

## Reproduce / refresh

```sh
../fetch-all-firmware.sh
column -t -s $'\t' ../firmware-manifest.tsv
```

To add a newly released version, follow the manifest row format in the
[README](../README.md#usage), then re-run the fetcher.
