using Distances
include("./Medoids/src/Medoids.jl")

# Load k-median problems in the OR-Library format
function loadOrLib(name::String)
    # TODO
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
