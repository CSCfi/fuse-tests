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
    length(ARGS) == 2 || error("usage: julia read_files.jl <directory> <N>")
    dir = ARGS[1]
    N = parse(Int, ARGS[2])
    order = shuffle!(collect(1:N))
    read_files("non-existent", Int[])  # precompile function
    @time read_files(dir, order)
end
