@testset verbose=true "Serialization tests" begin
    # Define a sample directory for testing
    test_directory = "test_data"

    # Create a directory for testing if it doesn't exist
    if !isdir(test_directory)
        mkdir(test_directory)
    end

    # Sample data for testing
    sample_ioexample = [IOExample(Dict(:x => x), 2x+1) for x ∈ 1:5]

    # Test write_IOexamples and read_IOexamples
    @testset "IOExample Serialization Tests" begin
        filename = joinpath(test_directory, "test_ioexample.xio")
        HerbData.write_IOexamples(filename, sample_ioexample)
        io_examples = HerbData.read_IOexamples(filename)
        @test length(io_examples) == 5
        @test string(io_examples) == string(sample_ioexample)
    end

    # Remove the test data directory after testing
    rm(test_directory; force=true, recursive=true)
end 
