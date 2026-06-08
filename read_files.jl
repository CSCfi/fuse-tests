using Random

function read_files(dir::AbstractString, order::Vector{Int})
    for i in order
        io = open(joinpath(dir, "$i"), "r")
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

    foo = [
        ("nocompression.sqfs", "/tmp/tollande/squashfs_fuse"),
        ("lz4.sqfs", "/tmp/tollande/squashfs_fuse_lz4"),
        ("zstd.sqfs", "/tmp/tollande/squashfs_fuse_zstd"),
        ("gzip.sqfs", "/tmp/tollande/squashfs_fuse_gzip"),
    ]

    run(`unsquashfs -dest /tmp/tollande/squashfs_tmp nocompression.sqfs`)
    println("/tmp fresh")
    @time read_files("/tmp/tollande/squashfs_tmp", order)
    println("/tmp cached")
    @time read_files("/tmp/tollande/squashfs_tmp", order)
    rm("/tmp/tollande/squashfs_tmp")

    for (sqfs_file, mountpoint) in foo
        mkpath(mountpoint)
        run(`squashfuse_ll $sqfs_file $mountpoint`)
        println("squashfuse_ll fresh $sqfs_file")
        @time read_files(mountpoint, order)
        println("squashfuse_ll cached $sqfs_file")
        @time read_files(mountpoint, order)
        run(`fusermount -u $mountpoint`)
        rm(mountpoint)
    end

    run(`unsquashfs -dest /scratch/project_2001659/squashfs_lustre nocompression.sqfs`)
    println("lustre scratch fresh")
    @time read_files("/scratch/project_2001659/squashfs_lustre", order)
    println("lustre scratch cached")
    @time read_files("/scratch/project_2001659/squashfs_lustre", order)
    rm("/scratch/project_2001659/squashfs_lustre")
end
