module HerbData

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
    in::Dict{Symbol, Any}
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
Parses a line from a file in the `pixels` dataset
"""
function parseline_pixels(line::AbstractString)::Tuple{Matrix{Bool}, Matrix{Bool}}
    # Helper function that converts a string to a list of booleans
    # Example: "0, 1, 1, 0" → [false, true, true, false]
    parseboollist(x) = map(y -> y == "1", split(x, ", "))
    
    # Extract data using RegEx
    matches = match(r"^pos\(w\([\d_]+,[\d_]+,(\d+),(\d+),\[([01, ]+)\]\)[,\)]w\([\d_]+,[\d_]+,(\d+),(\d+),\[([01, ]+)\]\)[,\)]\.$", line)
    
    # Parse data
    input_width = parse(Int, matches[1])
    input_height = parse(Int, matches[2])
    input = reshape(parseboollist(matches[3]), (input_width, input_height))
    output_width = parse(Int, matches[4])
    output_height = parse(Int, matches[5])
    output = reshape(parseboollist(matches[6]), (output_width, output_height))
    return (input, output)
end

end # module HerbData