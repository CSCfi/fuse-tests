function main()
    if length(ARGS) != 1
        println(stderr, "usage: $(PROGRAM_FILE) <N>")
        exit(1)
    end

    N_str = ARGS[1]

    if !occursin(r"^[1-9][0-9]*$", N_str)
        println(stderr, "error: N must be a positive integer, got: $N_str")
        exit(1)
    end

    N = parse(Int, N_str)

    # Create a temporary staging directory
    stage = mktempdir()

    # Ensure cleanup on exit
    try
        for i in 1:N
            data = read("/dev/urandom", 4096)
            write(joinpath(stage, string(i)), data)
        end

        run(`mksquashfs $stage gzip.sqfs -all-root -no-xattrs -noappend -b 128K -comp gzip`)
        run(`mksquashfs $stage zstd.sqfs -all-root -no-xattrs -noappend -b 128K -comp zstd`)
        run(`mksquashfs $stage lz4.sqfs -all-root -no-xattrs -noappend -b 128K -comp lz4`)
        run(`mksquashfs $stage nocompression.sqfs -all-root -no-xattrs -noappend -b 128K -noI -noD -noF -noX -no-fragments`)

        # ext4 image populated offline from $stage (no root, no mount), mirroring
        # mksquashfs. One 4096-byte file == one 4 KiB block. Force the inode count
        # (the default ratio gives only ~N/4 inodes and would abort mid-populate).
        # Journal kept for a fair ext4 comparison. Files are owned by the current
        # uid — there is no -all-root analogue without root, and fuse2fs reads them
        # back fine.
        ninodes = N + 16
        nblocks = N + cld(ninodes * 256, 4096) + 32768 + cld(N, 4) + 4096
        run(`mke2fs -q -F -t ext4 -b 4096 -N $ninodes -d $stage ext4.img $nblocks`)
    finally
        rm(stage; force=true, recursive=true)
    end
end

main()
