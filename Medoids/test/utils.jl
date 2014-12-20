using Base.Test

using Distances
using Medoids

d = 3
n = 200
s = 15

X = rand(d, n)
costs = pairwise(SqEuclidean(), X)
@assert size(costs) == (n, n)

medoids = filter(n -> n % s == 0, 1:n)
k = length(medoids)

function isCorrectMapping{T<:Real}(costs::DenseMatrix{T}, medoids::Vector{Int}, mapping::Vector{Int})
	for i in 1:length(mapping)
		if mapping[i] != medoids[indmin(map(m -> costs[i,m], medoids))]
			return false
		end
	end
	true
end

@test isCorrectMapping(costs, medoids, computeMedoidMap(costs, medoids))


