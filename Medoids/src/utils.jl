# utils.jl
using Distances
using Graphs

#### Common methods in algorithms
function calculateCost{T<:Real}(costs::DenseMatrix{T}, medoids::Array{Int})
    distances = costs[medoids[1], :]
    for m in medoids
        distances = min(distances, costs[m, :])
    end
    sum(distances)
end

#### Load problem instances

# Load k-median problems in the OR-Library format
# Returns (costs, k, optimum)
function loadOrLib(basePath::String, number::Int)
    1 <= number <= 40 || error("Only 40 OR-Library instances available")

    f = open(joinpath(basePath, "pmed$(number).txt"))
    nv, ne, k = [int(v) for v in split(strip(readline(f)))]
    costs = fill(typemax(Int32), nv, nv)
    for ln in eachline(f)
        ne -= 1
        i, j, distance = [int(v) for v in split(strip(ln))]
        costs[i, j] = costs[j, i] = distance
    end
    ne == 0 || error("$(ne) fewer lines than there should be")
    floyd_warshall!(costs)

    # Optimum value for each of the 40 problems
    opt = [5819, 4093, 4250, 3034, 1355, 7824, 5631, 4445, 2734, 1255,
    7696, 6634, 4374, 2968, 1729, 8162, 6999, 4809, 2845, 1789, 9138,
    8579, 4619, 2961, 1828, 9917, 8307, 4498, 3033, 1989, 10086, 9297,
    4700, 3013, 10400, 9934, 5057, 11060, 9423, 5128][number]

    costs, k, opt
end

#### Problem generation

# Generate random instance.  Based on Clustering.jl tests
# Returns (n points, cost matrix)
function randomInstance(dims::Int64, n::Int64)
    # Note that X[:, i] is the ith point
    X = rand(dims, n)
    costs = pairwise(SqEuclidean(), X)
    X, costs
end

#### Running tests

function testInstance(algorithms, costs, k, optimum::Int=-1)
    println("Finding $(k) medoids...")
    if optimum > 0
        println("Optimum $(optimum)")
    end
    for alg in algorithms
        println("-----------------------")
        println("Running $(methods(alg))...")
        tic()
        medoids = alg(costs, k)
        toc()
        println("Medoids: $(medoids)")
        println("Total cost: $(calculateCost(costs, medoids))")
    end
    println("=======================")
end
