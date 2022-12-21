module Data

export ProgramSynthesisProblem, InputOutputProblem

abstract type ProgramSynthesisProblem end

"""
A program synthesis problem that is represented in the form of input-output examples.
"""
struct InputOutputProblem <: ProgramSynthesisProblem
    examples::Vector{Tuple{Any, Any}}
    filename::AbstractString
end

"""
Reads all files in the given directory and parses them line by line into an 
`ExampleProblem` using the given lineparser.

*TODO: Turn this into an iterator that doesn't load all data into memory
at initialization.*
"""
function readdata(directory::AbstractString, lineparser)::Vector{ProgramSynthesisProblem}
    data::Vector{ProgramSynthesisProblem} = Vector([]) 
    for filename ∈ readdir(directory)
        filepath = joinpath(directory, filename)
        push!(data, readfile(filepath, lineparser))
    end
    return data
end


"""
Reads a file and parses every non-empty line using the line parser.
"""
function readfile(filepath::AbstractString, lineparser::Function)::InputOutputProblem
    file = open(filepath)
    examples::Vector{Tuple{Any, Any}} = map(lineparser, readlines(file))
    close(file)
    return InputOutputProblem(examples, basename(filepath))
end

"""
Parses a line from a file in the `strings` dataset
"""
function parseline_strings(line::AbstractString)::Tuple{String, String}
    # Helper function that converts a character list string to a string 
    # consisting of the characters
    # Example: "['A','B','C']" → "ABC"
    parsecharlist(x) = join([x[i] for i ∈ 3:4:length(x)])

    # Extract input and output lists using the RegEx
    matches = match(r"^[^\[\]]+(\[[^\[\]]+\])[^\[\]]+(\[[^\[\]]+\])", line)
    
    input = parse_char_list(matches[1])
    output = parse_char_list(matches[2])
    return (input, output)
end

"""
Parses a line from a file in the `robots` dataset
"""
function parseline_robots(line::AbstractString)::Tuple{Int[], Int[]}
    # Helper function that converts a string to a list of integers 
    # consisting of the characters
    # Example: "1,2,3" → [1, 2, 3]
    parseintlist(x) = map(y -> parse(Int, y), split(x, ","))

    # Remove unnecessary parts and split the input and output
    split_line = split(replace(line, "pos(w("=>"", "))."=>""), "),w(")
    
    input = parseintlist(split_line[1])
    output = parseintlist(split_line[2])
    return (input, output)
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

end # module