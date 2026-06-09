using Random

function read_files(dir::AbstractString, order::Vector{Int})
    for i in order
        io = open(joinpath(dir, string(i)), "r")
        read(io)
        close(io)
    end
    return nothing
end

if abspath(PROGRAM_FILE) == @__FILE__
    length(ARGS) == 1 || error("usage: julia read_files.jl <N>")
    N = parse(Int, ARGS[1])
    order = shuffle!(collect(1:N))

    # precompile function
    read_files("non-existent", Int[])

    tmp_root = mktempdir()

    run(`unsquashfs -dest $tmp_root/tmp nocompression.sqfs`)
    println("/tmp fresh")
    @time read_files("$tmp_root/tmp", order)
    println("/tmp cached")
    @time read_files("$tmp_root/tmp", order)

    file_mp = [
        ("nocompression.sqfs", "$tmp_root/fuse_squashfs_nocompression"),
        ("lz4.sqfs", "$tmp_root/fuse_squashfs_lz4"),
        ("zstd.sqfs", "$tmp_root/fuse_squashfs_zstd"),
        ("gzip.sqfs", "$tmp_root/fuse_squashfs_gzip"),
    ]
    for (sqfs_file, mountpoint) in file_mp
        mkpath(mountpoint)
        run(`squashfuse_ll $sqfs_file $mountpoint`)
        println("squashfuse_ll fresh $sqfs_file")
        @time read_files(mountpoint, order)
        println("squashfuse_ll cached $sqfs_file")
        @time read_files(mountpoint, order)
        run(`fusermount -u $mountpoint`)
    end

    lustre_root = mktempdir("/scratch/project_2001659")
    run(`unsquashfs -dest $lustre_root/lustre nocompression.sqfs`)
    println("lustre scratch fresh")
    @time read_files("$lustre_root/lustre", order)
    println("lustre scratch cached")
    @time read_files("$lustre_root/lustre", order)
end
