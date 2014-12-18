# Implementations of greedy k-median algorithms

function forwardGreedy{T<:Real}(costs::DenseMatrix{T}, k::Integer)
    n = size(costs, 1)
    size(costs, 2) == n || error("costs must be a square matrix.")
    k <= n || error("Number of medoids should be less than n.")

    start = indmin(sum(costs, 1)) # Index of min sum column
    closest = costs[start, :] # Distance from i to closest medoid
    medoids = Int64[start] # Current medoid set
    while length(medoids) < k
        best = (0, 0.) # (next id, improvement)
        for i in 1:n
            if !(i in medoids)
                # distance improvement by adding i
                gain = 0.0
                for j = 1:n
                    gain += max(closest[j] - costs[i, j], 0)
                end
                if gain > best[2]
                    best = (i, gain)
                end
            end
        end
        best[1] > 0 || error("Error finding medoid to add")
        push!(medoids, best[1])
        closest = min(closest, costs[best[1], :])
    end
    medoids
end

function backwardGreedy{T<:Real}(costs::DenseMatrix{T}, k::Integer)

end
