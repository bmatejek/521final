tests = ["utils", "pam"]

println("Running tests:")
for t in tests
    fp = "$(t).jl"
    println("* $fp ...")
    include(fp)
end
