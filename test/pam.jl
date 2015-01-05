using Base.Test

using Distances
using Medoids

d = 4
n = 200

X = rand(1:n, d, n) # test passes for integers, but FAILS for floats
costs = pairwise(SqEuclidean(), X)

@assert size(costs) == (n, n)

# use this as an example: https://github.com/JuliaStats/Clustering.jl/blob/master/test/kmedoids.jl
function testCalculateSwapValue()
	medoids = filter(i -> i % 2 == 0, 1:n)
	nonMedoids = filter(i -> !in(i, medoids), 1:n)
	#= println("X: $(X)")
	println("medoids: $(medoids)")
	println("nonMedoids: $(nonMedoids)")
	println("current cost: $(calculateCost(costs, medoids))") =#
	for i = 1:length(medoids)
		delta = calculateSwapValue(costs, Set(medoids), Set(nonMedoids), medoids[i], nonMedoids[i])
		medoidsCopy = copy(medoids)
		medoidsCopy[i] = nonMedoids[i]
		if delta != calculateCost(costs, medoidsCopy) - calculateCost(costs, medoids)
			#println("i: $(i), delta: $(delta), calculateCost result: $(calculateCost(costs, medoidsCopy))")
			return false
		end
	end
	true
end

@test testCalculateSwapValue()