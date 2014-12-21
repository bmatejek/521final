using Base.Test

# using Distances

d = 3
n = 20
k = 8

X = rand(d, n)
costs = pairwise(SqEuclidean(), X)

@assert size(costs) == (n, n)

# use this as an example: https://github.com/JuliaStats/Clustering.jl/blob/master/test/kmedoids.jl
R = pam(costs, k)



