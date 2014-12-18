# Implementations of greedy k-median algorithms

# Greedy algorith which repeatedly chooses the element that decreases the
# cost the most until k elements are chosen.
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
                    gain += max(closest[j] - costs[j, i], 0)
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

# Algorith which starts with a every point as a medoid and removes the
# point which increases the cost the least until there are k medoids
function reverseGreedy{T<:Real}(costs::DenseMatrix{T}, k::Integer)
    n = size(costs, 1)
    size(costs, 2) == n || error("costs must be a square matrix.")
    k <= n || error("Number of medoids should be less than n.")

    _reverseGreedyNaive(costs, k)
end

# Naive reverse greedy implementation as a ground truth for testing
# Recalculates complete cost for each removed medoid
function _reverseGreedyNaive(costs, k)
    medoids = IntSet(1:size(costs, 1))
    while length(medoids) > k
        bestM = (0, typemax(Float32))
        for m = medoids
            cost = calculateCost(costs, setdiff(medoids, [m]))
            if cost < bestM[2]
                bestM = (m, cost)
            end
        end
        delete!(medoids, bestM[1])
    end
    collect(Int, medoids)
end

# Currently broken - attempt at optimizing reverse greedy
function _reverseGreedyOpt(costs, k)
    medoids = Set(1:n)
    # closest[i] = id of medoid closest to i
    closest = [1:n]
    # use[i] = set of ids with i as closest medoid
    use = [Set(i) for i in 1:n]

    while length(medoids) > k
        toRemove, _, newNearest = _medoidToRemove(costs, medoids, closest, use)
        delete!(medoids, toRemove)
        curCluster = collect(Int, use[toRemove])
        closest[curCluster] = newNearest # Reassign clusters
        for (v, newCluster) = zip(curCluster, newNearest)
            push!(use[newCluster], v)
        end
    end
    collect(Int, medoids)
end

function _medoidToRemove(costs, medoids, closest, use)
    # id, loss, new nearest medoid for each point in cluster
    bestM = (0, typemax(Float32), [])
    # Get medoid with smallest increase in objective when removed
    for candidate = medoids
        loss, newNearest = _removalLoss(costs, medoids, closest, use, candidate)
        if loss < bestM[2]
            bestM = (candidate, loss, newNearest)
        end
    end
    bestM
end

function _removalLoss(costs, medoids, closest, use, candidate)
    loss = 0.
    newNearest = zeros(length(use[candidate]))
    for (i, p) in enumerate(use[candidate])
        # Get the new nearest for p
        newM = (0, typemax(Float32))
        for m in medoids
            if m != candidate
                cost = costs[m, p]
                if cost < newM[2]
                    newM = (m, cost)
                end
            end
        end
        loss += newM[2] - costs[candidate, p]
        newNearest[i] = candidate
    end
    (loss, newNearest)
end
