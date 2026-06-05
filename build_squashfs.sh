#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "usage: $0 <N> <output.squashfs>" >&2
    exit 1
fi

N=$1
OUT=$2

if [[ ! "$N" =~ ^[1-9][0-9]*$ ]]; then
    echo "error: N must be a positive integer, got: $N" >&2
    exit 1
fi

stage=$(mktemp -d -p "${TMPDIR:-/tmp}")
trap 'rm -rf "$stage"' EXIT

for ((i = 1; i <= N; i++)); do
    head -c 4096 /dev/urandom > "$stage/$i"
done

#mksquashfs "$stage" "$OUT" -noappend -comp gzip -b 128K -all-root -no-xattrs
#mksquashfs "$stage" "$OUT" -noappend -comp zstd -b 128K -all-root -no-xattrs
#mksquashfs "$stage" "$OUT" -noappend -comp lz4 -b 128K -all-root -no-xattrs
mksquashfs "$stage" "$OUT" -noappend -noI -noD -noF -noX -no-fragments -b 128K -all-root -no-xattrs
