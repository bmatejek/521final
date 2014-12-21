push!(LOAD_PATH,joinpath(dirname(@__FILE__()), "../src"))

tests = ["utils", "pam"]

println("Running tests:")
for t in tests
    fp = "$(t).jl"
    println("* $fp ...")
    include(fp)
end
