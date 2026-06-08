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

    println("/tmp fresh")
    @time read_files("/tmp/tollande/squashfs_tmp", order)

    println("/tmp cached")
    @time read_files("/tmp/tollande/squashfs_tmp", order)

    println("squashfuse_ll no-compression fresh")
    @time read_files("/tmp/tollande/squashfs_fuse", order)

    println("squashfuse_ll no-compression cached")
    @time read_files("/tmp/tollande/squashfs_fuse", order)

    println("squashfuse_ll lz4 fresh")
    @time read_files("/tmp/tollande/squashfs_fuse_lz4", order)

    println("squashfuse_ll lz4 cached")
    @time read_files("/tmp/tollande/squashfs_fuse_lz4", order)

    println("squashfuse_ll zstd fresh")
    @time read_files("/tmp/tollande/squashfs_fuse_zstd", order)

    println("squashfuse_ll zstd cached")
    @time read_files("/tmp/tollande/squashfs_fuse_zstd", order)

    println("squashfuse_ll gzip fresh")
    @time read_files("/tmp/tollande/squashfs_fuse_gzip", order)

    println("squashfuse_ll gzip cached")
    @time read_files("/tmp/tollande/squashfs_fuse_gzip", order)

    println("lustre scratch fresh")
    @time read_files("/scratch/project_2001659/squashfs_lustre", order)

    println("lustre scratch cached")
    @time read_files("/scratch/project_2001659/squashfs_lustre", order)
end
