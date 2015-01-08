global alg
global id
global performance
global runtime

algs = Dict()
for name in ARGS
    f = open(name)
    for ln in eachline(f)
        s = [strip(x) for x in split(ln)]
        if s[1] == "alg:"
            alg = s[2]
        elseif s[1] == "instanceNumber:"
            id = int(s[2])
        elseif s[1] == "performance:"
            performance = float(s[2])
        elseif s[1] == "time:"
            runtime = float(s[2])
        end
    end
    if !haskey(algs, alg)
        algs[alg] = (zeros(40), zeros(40))
    end
    algs[alg][1][id] = performance
    algs[alg][2][id] = runtime
end

opt = [5819, 4093, 4250, 3034, 1355, 7824, 5631, 4445, 2734, 1255,
7696, 6634, 4374, 2968, 1729, 8162, 6999, 4809, 2845, 1789, 9138,
8579, 4619, 2961, 1828, 9917, 8307, 4498, 3033, 1989, 10086, 9297,
4700, 3013, 10400, 9934, 5057, 11060, 9423, 5128]

names = keys(algs) 
println("Opt $(join(names, " "))")
for i = 1:40
    print("$(opt[i]) ")
    for alg in names
        print("$(algs[alg][1][i]) ")
    end
    print("\n")
end
