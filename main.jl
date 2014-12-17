using Distances
using Graphs
include("./Medoids/src/Medoids.jl")

# Load k-median problems in the OR-Library format
function loadOrLib(name::String)
    f = open(name)
    nv, ne, k = [int(v) for v in split(strip(readline(f)))]
    costs = fill(typemax(Int32), nv, nv)
    for ln in eachline(f)
        ne -= 1
        i, j, k = [int(v) for v in split(strip(ln))]
        costs[i, j] = costs[j, i] = k
    end
    if ne > 0
        println("$(ne) fewer lines than there should be")
    end
    floyd_warshall!(costs)
    costs, k
end

# Generate random instance.  Based on Clustering.jl tests
# Returns (n points, cost matrix)
function randomInstance(dims::Int64, n::Int64)
    # Note that X[:, i] is the ith point
    X = rand(dims, n)
    costs = pairwise(SqEuclidean(), X)
    X, costs
end

# Generate random instance, test with parkJun algorithm
d = 5
n = 100
k = 5
points, costs = randomInstance(d, n)
result = Medoids.parkJun(costs, k)
print("Total cost: $(result.totalcost)\n")
print("Medoids $(result.medoids)\n")
