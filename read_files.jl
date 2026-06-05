using Random

function read_files(dir::AbstractString, N::Integer)
    order = shuffle!(collect(1:N))
    for i in order
        io = open(joinpath(dir, "$i"), "r")
        read(io)
        close(io)
    end
    return nothing
end

if abspath(PROGRAM_FILE) == @__FILE__
    length(ARGS) == 2 || error("usage: julia read_files.jl <directory> <N>")
    dir = ARGS[1]
    N = parse(Int, ARGS[2])
    read_files("non-existent", 0)  # precompile function
    @time read_files(dir, N)
end
