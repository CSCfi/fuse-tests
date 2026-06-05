using Random

function write_files(dir::AbstractString, N::Integer)
    buf = rand(UInt8, 4096)
    for i in 1:N
        io = open(joinpath(dir, "$i"), "w")
        write(io, buf)
        close(io)
    end
    return nothing
end

if abspath(PROGRAM_FILE) == @__FILE__
    length(ARGS) == 2 || error("usage: julia write_files.jl <directory> <N>")
    dir = ARGS[1]
    N = parse(Int, ARGS[2])
    write_files("non-existent", 0)  # precompile function
    @time write_files(dir, N)
end
