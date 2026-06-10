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

    # Empty ext4 image sized to hold N 4096-byte files written later via fuse2fs.
    # One 4096-byte file == one 4 KiB block. Force the inode count (the default
    # ratio gives only ~N/4 inodes and would run out of inodes mid-write).
    # Journal kept for a fair ext4 comparison. Files written via fuse2fs -o fakeroot
    # are owned by the current uid.
    ninodes = N + 16
    nblocks = N + cld(ninodes * 256, 4096) + 32768 + cld(N, 4) + 4096
    run(`mke2fs -q -F -t ext4 -b 4096 -N $ninodes ext4.img $nblocks`)
end

main()
