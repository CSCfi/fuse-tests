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

    tmp_dir = joinpath(tmp_root, "tmp")
    run(`unsquashfs -dest $tmp_dir nocompression.sqfs`)
    println("$tmp_dir fresh")
    @time read_files(tmp_dir, order)
    println("$tmp_dir cached")
    @time read_files(tmp_dir, order)

    file_mp = [
        (abspath("nocompression.sqfs"), joinpath(tmp_root, "fuse_squashfs_nocompression")),
        (abspath("lz4.sqfs"), joinpath(tmp_root, "fuse_squashfs_lz4")),
        (abspath("zstd.sqfs"), joinpath(tmp_root, "fuse_squashfs_zstd")),
        (abspath("gzip.sqfs"), joinpath(tmp_root, "fuse_squashfs_gzip")),
    ]
    for (sqfs_file, mountpoint) in file_mp
        mkpath(mountpoint)
        run(`squashfuse_ll $sqfs_file $mountpoint`)
        println("$sqfs_file via squashfuse_ll fresh")
        @time read_files(mountpoint, order)
        println("$sqfs_file via squashfuse_ll cached")
        @time read_files(mountpoint, order)
        run(`fusermount -u $mountpoint`)
    end


    lustre_scratch_tmp = mktempdir("/scratch/project_2001659")

    lustre_scratch_dir = joinpath(lustre_scratch_tmp, "lustre_scratch")
    run(`unsquashfs -dest $lustre_scratch_dir nocompression.sqfs`)
    println("$lustre_scratch_dir fresh")
    @time read_files(lustre_scratch_dir, order)
    println("$lustre_scratch_dir cached")
    @time read_files(lustre_scratch_dir, order)

    ext4_mp = joinpath(lustre_scratch_tmp, "fuse_ext4")
    mkpath(ext4_mp)
    run(`fuse2fs $(abspath("ext4.img")) $ext4_mp -o ro,fakeroot`)
    println("ext4.img via fuse2fs fresh")
    @time read_files(ext4_mp, order)
    println("ext4.img via fuse2fs cached")
    @time read_files(ext4_mp, order)
    run(`fusermount -u $ext4_mp`)
end
