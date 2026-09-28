# Stock eMMC dump teardown: AD5M FW 2.7.2 (AceOfBase)

Teardown of a full-eMMC dump of a stock, unmodified Adventurer 5M running
FlashForge firmware **2.7.2**. An independent stock unit, useful as a recovery
reference and as a cross-check of the partition layout.

Provenance: `emmc_backup_AceOfBase_dump.bin_pass_123.zip` (zip password `123`),
shipped alongside the [T113-S4 RAM upgrade kit](../../reforge/docs/board-notes/t113-s4-256mb-ram-upgrade.md).
A **7.82 GB** raw image (`emmc_backup_AceOfBase_dump.bin`, Stored / uncompressed),
dated 2025-01-25, dumped by community user **AceOfBase**.

The 7.82 GB image itself is not committed. This writeup is the artifact-grounded
record; if the image is archived it belongs under `fw-archive/blobs/` or
`reforge/tools/recovery/` alongside the other full-eMMC images.

## Method

Loop-free, no root: each partition was carved out with `dd` at its GPT offset and
read with `debugfs` (ext4) / `strings` (boot image), e.g.

```
dd if=emmc_full.bin of=rootfs.img bs=512 skip=219148 count=2621440 status=none
debugfs -R 'cat /root/version' rootfs.img
```

## Identity

| field | value | source |
|---|---|---|
| Firmware | **2.7.2** | `/root/version` |
| Modded? | **No** (stock) | no `/opt/config/mod`; `/etc/issue` = "Welcome to Allwinner KunoOS Platform" (Tina brand) |
| Kernel | **5.4.61**, Linaro GCC 5.3-2016.05, `#52 SMP PREEMPT Wed Aug 23 2023` | `strings boot.img` |
| Model | Adventurer 5M (eboard MCU pins, `rotation_distance: 4.7`) | `/opt/config/printer.cfg` |
| rootfs | ext4, 1.28 GiB total, ~824 MiB used / ~456 MiB free | `debugfs show_super_stats` |

The kernel string matches [`stock-kernel-genealogy.md`](../../reforge/docs/reverse-engineering/stock-kernel-genealogy.md):
Linux 5.4.61 built with the 2016-era Linaro 5.3 toolchain that ships inside the
Tina SDK. Build `#52`, August 2023.

## Partition layout

GPT, seven partitions, **byte-for-byte identical** to the canonical layout in
[`partition-map.md`](../../reforge/docs/board-notes/partition-map.md), confirming
that document against an independent stock unit:

| # | name | start (LBA) | size | FS | role |
|---|---|---:|---|---|---|
| 1 | boot-resource | 73 728 | 33.6 MiB | vfat | splash / MCU staging |
| 2 | env | 142 604 | 1 MiB | u-boot env | primary env |
| 3 | env-redund | 144 652 | 1 MiB | u-boot env | redundant env |
| 4 | boot | 146 700 | 34.4 MiB | Android bootimg | kernel (0x40008000) + ramdisk (0x41000000) + DTB |
| 5 | dsp0 | 217 100 | 1 MiB | raw | HiFi4 DSP firmware |
| 6 | rootfs | 219 148 | 1.3 GiB | ext4 | `/` (Buildroot rootfs) |
| 7 | UDISK | 2 840 588 | 5.9 GiB | ext4 | `/data` (user data) |

`boot0` (Allwinner eGON.BT0 SPL) lives in the first 36 MiB reserved area before
the GPT, as documented in the partition map.

## Notable contents

- `/opt/config/`: `printer.cfg`, `printer.base.cfg`, per-model JSONs
  (`ad5m.json`, `Adventurer5M.json`, and others FlashForge ships).
- `/root/`: `mcu.img` / `start.img` / `end.img` (MCU firmware staging images),
  `version`, `boot.img`, `avatar_default.png`, plus the owner's
  `.bash_history` (trivial: only `date` / `date -s '2024-06-09 ...'`) and
  `.viminfo`.

## Use as recovery reference

This is a clean stock-2.7.2 image, suitable as a source for the eMMC-reader
recovery path (RUNBOOK Path B) on a unit with no FEL access. For the T113-S4
modded boards, FEL is available and the boot0/DTB are flashed directly (see the
[upgrade doc](../../reforge/docs/board-notes/t113-s4-256mb-ram-upgrade.md)).
