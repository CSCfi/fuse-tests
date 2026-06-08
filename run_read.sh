#!/usr/bin/env bash

# environment
module purge
module load julia

# TODO: refactor as Julia script
# TODO: add output details

# setup
mkdir -p /tmp/tollande/squashfs_fuse
squashfuse_ll nocomp.sqfs /tmp/tollande/squashfs_fuse

# TODO: also time unsquashfs time
unsquashfs -dest /tmp/tollande/squashfs_tmp nocomp.sqfs > /dev/null
unsquashfs -dest /scratch/project_2001659/squashfs_lustre nocomp.sqfs > /dev/null

# benchmark
# TODO: run many tests with same file access order

echo "/tmp fresh"
julia read_files.jl /tmp/tollande/squashfs_tmp 10000
echo "/tmp cached"
julia read_files.jl /tmp/tollande/squashfs_tmp 10000

echo "squashfuse_ll fresh"
julia read_files.jl /tmp/tollande/squashfs_fuse 10000
echo "squashfuse_ll cached"
julia read_files.jl /tmp/tollande/squashfs_fuse 10000

echo "lustre scratch fresh"
julia read_files.jl /scratch/project_2001659/squashfs_lustre 10000
echo "lustre scratch cached"
julia read_files.jl /scratch/project_2001659/squashfs_lustre 10000

# cleanup
fusermount -u /tmp/tollande/squashfs_fuse
rmdir /tmp/tollande/squashfs_fuse
rm -rf /tmp/tollande/squashfs_tmp
rm -rf /scratch/project_2001659/squashfs_lustre
