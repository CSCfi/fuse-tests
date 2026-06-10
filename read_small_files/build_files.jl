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

        # TODO: create ext4 image with files from $stage
    finally
        rm(stage; force=true, recursive=true)
    end
end

main()
