# Stock firmware 5.1.7: exact diff vs 5.1.4

OTA-advertised current Adventurer 5M **Pro** release, compared file-by-file
against the previous public Pro build (**5.1.4**). Method: extract both
official OTA tarballs, SHA-256 every member, then SHA-256 every file inside
the four component archives. Outer `.tgz` / inner `*.tar.xz` are plain `tar`.

**Result: 5.1.7 changes only `firmwareExe` (+354 B) and the software
`md5sum.list` line for that binary.** Kernel, MCU, library, installer, splash
images, and every other software file are byte-identical to 5.1.4.

There is no public 5.1.5/5.1.6 for the Pro. An unlisted Pro **5.1.8** exists
on OSS (not OTA-advertised); 5M has since shipped **5.1.9**. See
[`stock-fw-5.1.8-diff.md`](stock-fw-5.1.8-diff.md) and
[`stock-fw-5.1.9-diff.md`](stock-fw-5.1.9-diff.md).

## Provenance

| field | 5.1.4 | 5.1.7 |
|---|---|---|
| artifact | `Adventurer5MPro-5.1.4-2.2.3-20260515.tgz` | `Adventurer5MPro-5.1.7-2.2.3-20260605.tgz` |
| date | 2026-05-15 | 2026-06-05 |
| size / sha256 | 68290560 B · `80e98c82b028c2c1…0f07` | 68290560 B · `58076910fe0a659f…5ffd` |
| source | official OSS, linked from the [Pro download page](https://www.flashforge.com/blogs/download-document/adventurer-5m-pro) | same |

Live OTA (`update.voxelshare.com`, `app_id=35` `platform=29`, probed
2026-09-11): a printer on 5.1.4 is offered **v5.1.7**. A printer on 5.1.7
gets `Latest release version not found` (no newer advertised build). Official
changelist shipped with that offer:

1. Optimized the offline reconnection mechanism for Flash Studio.
2. Added grayed-out display for "My Account" information when offline.
3. Fixed errors with resuming prints after power outages.
4. Resolved page lagging issues when offline.
5. Fixed other known bugs.

## Package layout (unchanged)

```
software-<ver>.tar.xz   firmwareExe (Qt UI) + run.sh + ntpclient + md5sum.list
kernel-2.1.6.tar.xz     uImage, sunxi.dtb, 8821cu.ko, rcS, bootlogo, udhcpd.conf
library-2.5.0.tar.xz    ffstartup-arm, nim.tar, create-rsa.sh, *.cfg
control-2.2.3.tar.xz    MCU: Mainboard-20230831.bin, Eboard-20231012.hex
boot.img start.img end.img  splash/boot images
flashforge_init.sh inittab shadow mencoder play Cube-PLA-Test.gx
```

The kernel/control/library **wrapper** tarballs have different sha256 between
5.1.4 and 5.1.7 (non-reproducible tar metadata). Extracted payloads, including
those components' `md5sum.list` files, are identical.

## Exact file inventory (58 files each)

Compared with the `software-<ver>/` prefix stripped. 56 identical, 2 changed,
0 added, 0 removed.

| path | 5.1.4 | 5.1.7 |
|---|---|---|
| `software/firmwareExe` | 9 564 448 B · sha256 `4808d7405d495df8…e097` · BuildID `f24ce894…6932` | 9 564 802 B · sha256 `2765a1d432118269…102e` · BuildID `c4a4482f…0ba1` · **+354 B** |
| `software/md5sum.list` | 1302 B · `91590713698aa956…090e` | 1302 B · `dd230dc79912e28a…94f2` (only the `firmwareExe` MD5 line: `bbc19557…` → `1b685cc6…`) |

Everything else, including `uImage` / `sunxi.dtb` / `8821cu.ko` / both MCU
blobs / `nim.tar` / `ffstartup-arm` / `flashforge_init.sh` / `run.sh` /
`ntpclient` / `client/*` / splash images / `mencoder` / `play`, is
byte-identical.

## `firmwareExe` string delta

Human-readable strings that actually describe behavior (the rest is compiler
noise from a not-stripped rebuild):

- **removed:** paho-MQTT `SSLSocket.c` https-proxy log strings (`Setting https
  proxy to %s`, `https_proxy`). paho version is still `paho.mqtt.c-1.3.13`.
- **added:** `/opt/klipper/klippy/extras/virtual_sdcard.py`, `/root/version`,
  `MQTT connection ok` / `MQTT Reconnected:` / `MQTT connect error:`.
- **hostnames / URLs: no change.** Same FlashForge / VoxelShare / NetEase /
  Polar / sz3dp / `pool.ntp.org` set as 5.1.4. The plaintext-HTTP dev OTA
  server `http://10.33.11.172:32112` is still compiled in.

## ReForge impact: none required for 5.1.7

- cloudblock host set is complete for this build (no new endpoints).
- kernel / dtb / `8821cu.ko` byte-identical with every 3.1.3–5.1.7 unit.
- MCU firmware unchanged (`control-2.2.3`).
- `flashforge_init.sh` / `inittab` unchanged: USB `.tgz` install still works.

## Reproduce

```sh
A=blobs/stock
# already fetched by ../fetch-all-firmware.sh
mkdir -p /tmp/fw514 /tmp/fw517
tar -xf "$A/Adventurer5MPro-5.1.4.tgz" -C /tmp/fw514
tar -xf "$A/Adventurer5MPro-5.1.7.tgz" -C /tmp/fw517
tar -xf /tmp/fw514/software-5.1.4.tar.xz -C /tmp/fw514
tar -xf /tmp/fw517/software-5.1.7.tar.xz -C /tmp/fw517
cmp /tmp/fw514/firmwareExe /tmp/fw517/firmwareExe   # differs; only payload that does
```
