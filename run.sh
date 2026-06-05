#!/usr/bin/env bash

# environment
module purge
module load julia

# setup
mkdir -p /tmp/tollande/squashfs_fuse
squashfuse test.sqfs /tmp/tollande/squashfs_fuse
unsquashfs -dest /tmp/tollande/squashfs_tmp test.sqfs > /dev/null
unsquashfs -dest ./squashfs_lustre test.sqfs > /dev/null

# benchmark
julia read_files.jl /tmp/tollande/squashfs_tmp 10000
julia read_files.jl /tmp/tollande/squashfs_fuse 10000
julia read_files.jl ./squashfs_lustre 10000

# cleanup
fusermount -u /tmp/tollande/squashfs_fuse
rmdir /tmp/tollande/squashfs_fuse
rm -rf /tmp/tollande/squashfs_tmp
rm -rf ./squashfs_lustre
