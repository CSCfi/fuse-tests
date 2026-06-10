using Random
include("write_files.jl")

if abspath(PROGRAM_FILE) == @__FILE__
    length(ARGS) == 1 || error("usage: julia run.jl <N>")
    N = parse(Int, ARGS[1])
    buf = rand(UInt8, 4096)

    # precompile function
    write_files("non-existent", 0, buf; fsync=true)

    tmp_root = mktempdir()

    # Lustre scratch
    lustre_scratch_tmp = mktempdir("/scratch/project_2001659")
    lustre_scratch_dir = joinpath(lustre_scratch_tmp, "lustre_scratch")
    mkpath(lustre_scratch_dir)
    println("$lustre_scratch_dir")
    @time write_files(lustre_scratch_dir, N, buf; fsync=true)

    # fuse2fs ext4 (read-write)
    ext4_mp = joinpath(tmp_root, "fuse_ext4")
    mkpath(ext4_mp)
    ext4_img = abspath("ext4.img")
    run(`fuse2fs $ext4_img $ext4_mp -o fakeroot`)
    println("$ext4_img via fuse2fs")
    @time write_files(ext4_mp, N, buf; fsync=true)
    run(`fusermount -u $ext4_mp`)

    # cleanup
    rm(lustre_scratch_tmp; force=true, recursive=true)
    rm(tmp_root; force=true, recursive=true)
end
