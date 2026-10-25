#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp "$DIR/fetch-all-firmware.sh" "$TMP/"
mkdir -p "$TMP/components"
for component in software kernel library control; do
    touch "$TMP/components/$component-1.0.tar.xz"
done
tar -cf "$TMP/package.tgz" -C "$TMP/components" .
head -1 "$DIR/firmware-manifest.tsv" > "$TMP/firmware-manifest.tsv"
printf '5M\t1.0\t20261025\t-\t-\t-\t-\t-\t-\t-\t-\tfile://%s/package.tgz\n' "$TMP" >> "$TMP/firmware-manifest.tsv"
bash "$TMP/fetch-all-firmware.sh" > /dev/null
cmp "$TMP/package.tgz" "$TMP/blobs/stock/Adventurer5M-1.0.tgz"
awk -F '\t' 'NR == 2 {if (NF != 12 || $5 != "Adventurer5M-1.0.tgz" || $8 != "1.0" || $9 != "1.0" || $10 != "1.0" || $11 != "1.0") exit 1}' "$TMP/firmware-manifest.tsv"
cp "$TMP/firmware-manifest.tsv" "$TMP/expected.tsv"
bash "$TMP/fetch-all-firmware.sh" > /dev/null
cmp "$TMP/expected.tsv" "$TMP/firmware-manifest.tsv"
# A failed download must preserve the only copy of the source URLs and checksums.
rm "$TMP/package.tgz" "$TMP/blobs/stock/Adventurer5M-1.0.tgz"
if bash "$TMP/fetch-all-firmware.sh" > /dev/null 2>&1; then
    echo 'Expected a failed download' >&2
    exit 1
fi
cmp "$TMP/expected.tsv" "$TMP/firmware-manifest.tsv"
echo 'Fetcher checks passed: download, fingerprint, repeat run, failure preservation.'
