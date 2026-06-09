#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "usage: $0 <N>" >&2
    exit 1
fi

N=$1

if [[ ! "$N" =~ ^[1-9][0-9]*$ ]]; then
    echo "error: N must be a positive integer, got: $N" >&2
    exit 1
fi

stage=$(mktemp -d -p "${TMPDIR:-/tmp}")
trap 'rm -rf "$stage"' EXIT

for ((i = 1; i <= N; i++)); do
    head -c 4096 /dev/urandom > "$stage/$i"
done

mksquashfs "$stage" "gzip.sqfs" -all-root -no-xattrs -noappend -b 128K -comp gzip
mksquashfs "$stage" "zstd.sqfs" -all-root -no-xattrs -noappend -b 128K -comp zstd
mksquashfs "$stage" "lz4.sqfs" -all-root -no-xattrs -noappend -b 128K -comp lz4
mksquashfs "$stage" "nocompression.sqfs" -all-root -no-xattrs -noappend -b 128K -noI -noD -noF -noX -no-fragments
