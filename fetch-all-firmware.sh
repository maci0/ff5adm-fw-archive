#!/usr/bin/env bash
# fetch-all-firmware.sh
#
# Download every stock firmware listed in firmware-manifest.tsv, record its
# sha256 + size, and fingerprint the component versions (software / kernel /
# library / control) inside each package. Emits firmware-manifest.tsv.
#
# Blobs are tracked under blobs/stock/. Existing non-empty files are reused.
#
# FF packages are quirky: the outer .tgz is a PLAIN (uncompressed) tar, and the
# inner *.tar.xz members are ALSO plain tar. Older releases ship the firmware
# inside a .zip or .rar wrapper. This script normalizes all three.
#
# Usage: ./fetch-all-firmware.sh
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${DIR}/blobs/stock"
MAN="${DIR}/firmware-manifest.tsv"
mkdir -p "${OUT}"

[ -f "${MAN}" ] || { echo "no ${MAN}"; exit 1; }
TMP_MAN="$(mktemp "${MAN}.XXXXXX")" || exit 1
trap 'rm -f "$TMP_MAN"' EXIT

printf 'model\tversion\tdate\tcontainer\tfile\tsize\tsha256\tsoftware\tkernel\tlibrary\tcontrol\turl\n' > "${TMP_MAN}"

# Print the component versions (software/kernel/library/control) inside a
# firmware package. Format-agnostic: FF mislabels containers (a ".rar" that is
# really a tar, ".tar.xz" that is plain tar), and the 2.x .zip holds the
# component tarballs loose in a subdir rather than an inner firmware tar. So we
# just LIST the archive by its real magic and grep the `<comp>-<ver>.tar.xz`
# names out of the listing — no extraction needed.
fingerprint() {  # $1 = path to downloaded file -> "sw<TAB>kr<TAB>lb<TAB>ct"
    local f="$1" listing magic tmp
    magic="$(file -b "$f" 2>/dev/null)"
    if printf '%s' "$magic" | grep -q 'tar archive'; then
        # plain firmware tar (covers FF's mislabeled .tgz/.rar): components are tar members
        listing="$(tar -tf "$f" 2>/dev/null)"
    else
        # zip/rar wrapper: extract, then collect loose component tarball names AND
        # list any nested firmware tgz (older 2.x zips nest the whole .tgz one level down)
        tmp="$(mktemp -d)"
        if printf '%s' "$magic" | grep -qi 'zip archive'; then unzip -qo "$f" -d "$tmp" 2>/dev/null
        elif printf '%s' "$magic" | grep -qi 'rar archive'; then unrar x -inul "$f" "$tmp/" 2>/dev/null; fi
        listing="$(find "$tmp" -name '*.tar.xz' -printf '%f\n' 2>/dev/null)"
        local nested
        for nested in $(find "$tmp" -iname 'Adventurer5M*.tgz' -o -iname 'Adventurer5M*.tar' 2>/dev/null); do
            listing="${listing}"$'\n'"$(tar -tf "$nested" 2>/dev/null)"
        done
        rm -rf "$tmp"
    fi
    local names; names="$(printf '%s\n' "$listing" | grep -oE '(software|kernel|library|control)-[0-9][0-9.]*\.tar\.xz' | sort -u)"
    local sw kr lb ct
    sw="$(printf '%s\n' "$names" | sed -n 's/^software-\(.*\)\.tar\.xz$/\1/p' | head -1)"
    kr="$(printf '%s\n' "$names" | sed -n 's/^kernel-\(.*\)\.tar\.xz$/\1/p' | head -1)"
    lb="$(printf '%s\n' "$names" | sed -n 's/^library-\(.*\)\.tar\.xz$/\1/p' | head -1)"
    ct="$(printf '%s\n' "$names" | sed -n 's/^control-\(.*\)\.tar\.xz$/\1/p' | head -1)"
    printf '%s\t%s\t%s\t%s' "${sw:-?}" "${kr:-?}" "${lb:-?}" "${ct:-?}"
}

cut -f1-3,12 "${MAN}" | grep -vE '^#|^[[:space:]]*$' | while IFS=$'\t' read -r model version date url; do
    [ "$model" = "model" ] && continue
    [ -n "$url" ] || continue
    ext="${url##*.}"; case "$ext" in zip|rar|tgz) : ;; *) ext="tgz" ;; esac
    file="${OUT}/Adventurer${model}-${version}.${ext}"
    if [ ! -s "$file" ]; then
        echo "[fetch] ${model} ${version} ..."
        curl -fsSL -o "$file" "$url" || { echo "  FAIL ${model} ${version}"; rm -f "$file"; exit 1; }
    else
        echo "[have ] ${model} ${version}"
    fi
    size="$(stat -c%s "$file")"
    sha="$(sha256sum "$file" | cut -d' ' -f1)"
    fp="$(fingerprint "$file")"
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$model" "$version" "$date" "$ext" "$(basename "$file")" "$size" "$sha" "$fp" "$url" >> "${TMP_MAN}"
done || exit 1

mv "$TMP_MAN" "$MAN" || exit 1

echo ""
echo "manifest -> ${MAN}"
column -t -s $'\t' "${MAN}" 2>/dev/null | head -40
