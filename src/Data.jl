module Data

using Serialization
using ..Grammars

export 
    Problem,
    Example,
    IOExample

abstract type Example end

"""
A program synthesis problem.
"""
struct Problem
    examples::AbstractVector{Example}
    filename::AbstractString
end

"""
An input-output example.
"""
struct IOExample <: Example
    in::Any
    out::Any
end

"""
Reads all files in the given directory and parses them line by line into an 
`ExampleProblem` using the given lineparser.

*TODO: Turn this into an iterator that doesn't load all data into memory
at initialization.*
"""
function readdata(directory::AbstractString, lineparser::Function)::Vector{Problem}
    data::Vector{Problem} = Vector([]) 
    for filename ∈ readdir(directory)
        filepath = joinpath(directory, filename)
        push!(data, readfile(filepath, lineparser))
    end
    return data
end


"""
Reads a file and parses every non-empty line using the line parser.
"""
function readfile(filepath::AbstractString, lineparser::Function)::Problem
    file = open(filepath)
    examples::Vector{Example} = map(lineparser, readlines(file))
    close(file)
    return Problem(examples, basename(filepath))
end


"""
Writes IO examples to disk by serializing them into a file using HDF5 checking for and appending the `.xio` file ending.
"""
function write_IOexamples(filepath::AbstractString, examples::Vector{IOExample})
    serialize(filepath * (endswith(filepath, ".xio") ? "" : ".xio"), examples)
end

"""
Writes IO examples and the corresponding programs to disk by serializing them into a file using HDF5 checking for and appending the `.xiop`.
"""
function write_IOPexamples(filepath::AbstractString, examples::Vector{Tuple{Data.IOExample, Grammars.Expr}}
    serialize(filepath * (endswith(filepath, ".xiop") ? "" : ".xiop"), examples)
end

"""
Reads serialized IO examples from disk after type checking.
"""
function read_IOexamples(filepath::AbstractString)::Vector{IOExample}
    @assert endswith(filepath, ".xio")
    return deserialize(filepath)
end

"""
Reads serialized IO + program examples from disk after type checking.
"""
function read_IOPexamples(filepath::AbstractString)::Vector{Tuple{Data.IOExample, Grammars.Expr}}
    @assert endswith(filepath, ".xiop")
    return deserialize(filepath)
end

end # module
