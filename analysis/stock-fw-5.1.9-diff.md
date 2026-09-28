# Stock firmware 5.1.9: exact diff vs 5.1.7 (Adventurer 5M)

Current public Adventurer **5M** (non-Pro) release. Linked from the official
[5M download page](https://www.flashforge.com/blogs/download-document/adventurer-5m)
as `Firmware_5.1.9-2.2.3`. There is no matching Pro 5.1.9 object on OSS.

Baseline is 5M 5.1.7 (same date as Pro 5.1.7, 2026-06-05), also pulled from
official OSS. 5M 5.1.4 and 5.1.7 were missing from this archive until this
pass; they are now in `blobs/stock/` and `firmware-manifest.tsv`.

## Provenance

| field | 5M 5.1.7 | 5M 5.1.9 |
|---|---|---|
| artifact | `Adventurer5M-5.1.7-2.2.3-20260605.tgz` | `Adventurer5M-5.1.9-2.2.3-20260828.tgz` |
| date | 2026-06-05 | 2026-08-28 |
| size / sha256 | 68290560 B · `c0de8b3989ab24fb…3afa` | 68495360 B · `55257c0def0ce14d…2554` |
| source | official OSS `AD5M固件/` | official OSS `AD5M固件/`, linked from the 5M download page |

No 5M 5.1.8 object exists at the usual names (HEAD-probed 2026-09-11). 5.1.9
follows 5.1.7 directly on the public page.

## Exact file inventory vs 5M 5.1.7

Prefix-stripped comparison. 54 identical, 5 changed, **1 added**, 0 removed.

| path | 5.1.7 | 5.1.9 |
|---|---|---|
| **`software/config/server.json`** | (absent) | **201 B added** · sha256 `813045ab8248a14e…efc7` |
| `software/firmwareExe` | 9 560 556 B · sha256 `5ec55ff46dacaa50…3ab7` · BuildID `afb71827…a0eb` | 9 766 609 B · sha256 `31eee6a033acaeb1…aa4c` · BuildID `a594dccf…dc4f` · **+206 053 B** |
| `software/md5sum.list` | 1302 B | 1357 B (+55: new `./config/server.json` line + `firmwareExe` MD5) |
| `kernel-2.1.6/md5sum.list` | same 8 MD5s | same 8 MD5s, reordered |
| `control-2.2.3/md5sum.list` | same 7 MD5s | same 7 MD5s, reordered |
| `library-2.5.0/md5sum.list` | same 6 MD5s | same 6 MD5s, reordered |

Kernel / MCU / library **payloads** are byte-identical with 5M 5.1.7, Pro 5.1.7,
and Pro 5.1.8 (`uImage` 5 195 072 B, `8821cu.ko`, both MCU blobs, `nim.tar`).
5M-only outer files `freecach.sh` and the slightly larger `flashforge_init.sh`
(6436 B vs Pro 6266 B) are unchanged 5.1.4 → 5.1.9.

## New file: `software/config/server.json`

```json
{
    "platform": {
        "appUrl": "https://api.voxelshare.com",
        "healthxUrl": "https://api.fdmcloud.flashforge.com/healthx/liveness"
    },
    "update": {
        "testEnv": false
    }
}
```

Those two URLs were already hardcoded in 5.1.7 `firmwareExe`. 5.1.9 also reads
and rewrites this file (`initPlatformConfig: parse server.json failed, will
rewrite with defaults`, `savePlatformConfig`). `healthxUrl` is now a `Config`
getter/setter (`getPlatformHealthxUrl` / `setPlatformHealthxUrl`). Cloudblock
already pins both hosts.

## `firmwareExe` behavior delta (strings)

- **New outbound host: `https://ipinfo.io/country`.** Geo lookup, not in
  ReForge `S00cloudblock` as of this writing. Only this 5M 5.1.9 binary (Pro
  5.1.8 does not have it).
- **MQTT connect is now async:** `startConnectMqtt` →
  `startConnectMqttAsync` / `doConnectMqttInThread` / `connectMqttThreadFunc`.
  New logs: `MQTT connect thread start`, `MQTT already connected, skip`,
  `MQTT publish timeout`, `create MQTT connect thread error`.
- **Timelapse encode:** command string moves from `/opt/mencoder mf://` to
  `/opt/ffmpeg-4.0.2/bin/ffmpeg -nostdin -y -loglevel error -f image2
  -framerate 15 -i`. Same situation as Pro 5.1.8: `mencoder` is still in the
  outer package, ffmpeg is not. Untested on device.
- **Power-loss bak path:** `/data/AppConfig/PowerOff.bak` added.
- Toolchain prefix shuffle identical to Pro 5.1.8 (`/opt/ad5dm-env/gcc-linaro-…`).
- Legacy sz3dp OTA URLs (`update.sz3dp.com:10443` /
  `update.cn.sz3dp.com:10443`) **remain** in this 5M binary (Pro 5.1.8 dropped
  them). Dev OTA `http://10.33.11.172:32112` still compiled in.

## Cross-model (5M 5.1.9 vs Pro 5.1.8)

Same frozen kernel/MCU/library. Model-specific deltas that predate 5.1.9 and
are unchanged here:

- 5M has `freecach.sh`; Pro does not.
- `flashforge_init.sh` / `software/auto_run.sh` / `software/run.sh` differ
  (installer copy, 5M vs Pro).
- `firmwareExe` is a different binary (5M 9 766 609 B vs Pro 5.1.8 9 670 890 B).
- `server.json` and `ipinfo.io` are 5M 5.1.9 only.

## ReForge impact

- **cloudblock gap: `ipinfo.io`.** New in 5.1.9 `firmwareExe`
  (`https://ipinfo.io/country`). Not in `S00cloudblock`. VoxelShare /
  fdmcloud / Polar / sz3dp / NetEase hosts are already covered.
  `pool.ntp.org` still unblocked on purpose.
- **kernel / MCU / library:** still frozen. Byte-identical kernel work holds
  for 5M 5.1.9.
- **USB `.tgz` install:** 5M `flashforge_init.sh` unchanged 5.1.4 → 5.1.9.
- Z-Mod 1.7.3 (2026-09-09) lists "AD5M: Support for native firmware 5.1.9".
  That is their statement, not a ReForge test.

## Reproduce

```sh
A=blobs/stock
../fetch-all-firmware.sh    # 5M 5.1.4 / 5.1.7 / 5.1.9 are in firmware-sources.tsv
mkdir -p /tmp/m517 /tmp/m519
tar -xf "$A/Adventurer5M-5.1.7.tgz" -C /tmp/m517
tar -xf "$A/Adventurer5M-5.1.9.tgz" -C /tmp/m519
tar -xf /tmp/m517/software-5.1.7.tar.xz -C /tmp/m517
tar -xf /tmp/m519/software-5.1.9.tar.xz -C /tmp/m519
cmp /tmp/m517/firmwareExe /tmp/m519/firmwareExe        # differs
cat /tmp/m519/config/server.json                       # new file
```
