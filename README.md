# fw-archive — FlashForge Adventurer 5M / 5M Pro firmware archive

Canonical, workspace-level archive of **stock FlashForge AD5M / AD5M Pro
firmware** + the tooling and analysis built from it. Shared across the sibling
projects (`reforge/`, `forge-x/`) so the firmware blobs and checksums live in one
place instead of being duplicated per repo.

## Layout

```
fw-archive/
  firmware-sources.tsv      tracked — every release's URL (model, version, date, url)
  firmware-manifest.tsv     tracked — sha256 + size + component fingerprint per package
  fetch-all-firmware.sh     tracked — download + verify + fingerprint into blobs/stock/
  analysis/                 tracked — artifact-grounded writeups
    stock-fw-changelog.md     per-version component changelog (every downloadable release)
    stock-fw-5.1.7-diff.md    Pro 5.1.4 -> 5.1.7 (OTA-current Pro)
    stock-fw-5.1.8-diff.md    Pro 5.1.7 -> 5.1.8 (unlisted OSS)
    stock-fw-5.1.9-diff.md    5M 5.1.7 -> 5.1.9 (current 5M)
    stock-emmc-dump-2.7.2-aceofbase.md  full-eMMC dump teardown (stock 2.7.2 reference unit)
  blobs/                    GITIGNORED — the large binaries
    stock/                    the 26 stock OTA packages (2.3.x -> Pro 5.1.8 / 5M 5.1.9)
    sdk/                      Allwinner Tina SDK source (tina-linux.tar.gz)
    legacy/                   older ad-hoc firmwareExe/strings extracts (pre-archive)
```

Only the manifest, sources, scripts and analysis are version-controlled; the
blobs (~14 GB) are gitignored and reproduced on demand.

## Usage

```sh
./fetch-all-firmware.sh                 # download anything missing, (re)verify, fingerprint
column -t -s $'\t' firmware-manifest.tsv
```

To add a newly released version: append its row to `firmware-sources.tsv` and
re-run the fetcher (existing blobs are reused; only the new one downloads).

## What's here vs the repos

- **Here:** the raw firmware packages, their checksums, the fetch tooling, and
  the *version-level* analysis (what changed between releases).
- **`reforge/`:** the deeper reverse-engineering that builds on this archive —
  the `firmwareExe` teardown, the Tina-Auto **kernel genealogy**, the
  byte-identical kernel build, the cloud-block host set. Its
  `docs/reverse-engineering/` points here for the raw data.
- **`reforge/tools/recovery/`:** full-eMMC **recovery** images (golden.img) and
  device-recovery procedures — kept with the harness that consumes them, separate
  from this OTA-firmware archive.

## Provenance

Stock firmware is published by FlashForge as OTA overlays (official OSS:
`flashforge-resource.oss-*.aliyuncs.com` / `en.fss.flashforge.com`); versions FF
no longer hosts are pulled from the **ghzserg/FF** community mirror (a verified
re-host). Every package is pinned by sha256 in `firmware-manifest.tsv`. All FF
packages are plain `tar` despite `.tgz`/`.tar.xz`/`.rar` names (the fetcher
normalizes this).
