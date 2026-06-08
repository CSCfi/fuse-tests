#!/usr/bin/env bash

# environment
module purge
module load julia

# TODO: refactor as Julia script
# TODO: add output details

# setup
mkdir -p /tmp/tollande/squashfs_fuse
squashfuse_ll nocomp.sqfs /tmp/tollande/squashfs_fuse
mkdir -p /tmp/tollande/squashfs_fuse_gzip
squashfuse_ll gzip.sqfs /tmp/tollande/squashfs_fuse_gzip
mkdir -p /tmp/tollande/squashfs_fuse_lz4
squashfuse_ll lz4.sqfs /tmp/tollande/squashfs_fuse_lz4
mkdir -p /tmp/tollande/squashfs_fuse_zstd
squashfuse_ll zstd.sqfs /tmp/tollande/squashfs_fuse_zstd

unsquashfs -dest /tmp/tollande/squashfs_tmp nocomp.sqfs > /dev/null
unsquashfs -dest /scratch/project_2001659/squashfs_lustre nocomp.sqfs > /dev/null

# benchmark
julia read_files.jl 10000

# cleanup
fusermount -u /tmp/tollande/squashfs_fuse
rmdir /tmp/tollande/squashfs_fuse
fusermount -u /tmp/tollande/squashfs_fuse_gzip
rmdir /tmp/tollande/squashfs_fuse_gzip
fusermount -u /tmp/tollande/squashfs_fuse_lz4
rmdir /tmp/tollande/squashfs_fuse_lz4
fusermount -u /tmp/tollande/squashfs_fuse_zstd
rmdir /tmp/tollande/squashfs_fuse_zstd
rm -rf /tmp/tollande/squashfs_tmp
rm -rf /scratch/project_2001659/squashfs_lustre
