#!/usr/bin/env bash

# environment
module purge
module load julia

# setup
mkdir -p /tmp/tollande/squashfs_fuse
squashfuse_ll test.sqfs /tmp/tollande/squashfs_fuse
unsquashfs -dest /tmp/tollande/squashfs_tmp test.sqfs > /dev/null
unsquashfs -dest ./squashfs_lustre test.sqfs > /dev/null

# benchmark
echo "/tmp fresh"
julia read_files.jl /tmp/tollande/squashfs_tmp 10000
echo "/tmp cached"
julia read_files.jl /tmp/tollande/squashfs_tmp 10000
echo "squashfuse_ll fresh"
julia read_files.jl /tmp/tollande/squashfs_fuse 10000
echo "squashfuse_ll cached"
julia read_files.jl /tmp/tollande/squashfs_fuse 10000
echo "lustre scratch fresh"
julia read_files.jl ./squashfs_lustre 10000
echo "lustre scratch cached"
julia read_files.jl ./squashfs_lustre 10000

# cleanup
fusermount -u /tmp/tollande/squashfs_fuse
rmdir /tmp/tollande/squashfs_fuse
rm -rf /tmp/tollande/squashfs_tmp
rm -rf ./squashfs_lustre
