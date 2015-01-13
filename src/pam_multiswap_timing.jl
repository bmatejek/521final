# K-medoids implementation based on the commonly used PAM algorithm (Kaufman's original algorithm)
function pamMultiswap_timing{T<:Real}(costs::DenseMatrix{T}, k::Integer, time)
    # check arguments
    nf, nc = size(costs)
    k <= nf || error("Number of medoids should be less than nf")
    
    P = 2 # adjust this parameter to try different multiway swaps
    collect(swap_multitiming(costs, build(costs, k)..., P, time))
end

function build{T<:Real}(costs::DenseMatrix{T}, k::Integer)
	nf, nc = size(costs)

	medoids = Set{Int}()
	non_medoid_points = Set(1:nf)

	min_cost = typemax(Float64)
	first_medoid = -1
	for i = 1:nf
		cost = 0
		for j = 1:nc
			cost += costs[i,j]
		end
		if cost < min_cost
			min_cost = cost
			first_medoid = i
		end
	end

	push!(medoids, first_medoid)
	delete!(non_medoid_points, first_medoid)

    # initialize current cost dictionary
    dist_to_medoid = Dict{Int,Float64}()
    for i = 1:nc
    	dist_to_medoid[i] = costs[first_medoid,i]
    end
    
    while (length(medoids) < k)
    	min_next_medoid = -1
    	max_delta = typemin(Float64)
    	for i = 1:nf
    		if !in(i, medoids)
		# consider making i the next medoid
		delta = 0
		for j in 1:nc
			if dist_to_medoid[j] > costs[i,j]
				delta += dist_to_medoid[j] - costs[i,j]
			end
		end
		if delta > max_delta
			max_delta = delta
			min_next_medoid = i
		end
	end
end
push!(medoids, min_next_medoid)
for j in 1:nc
	if (costs[min_next_medoid, j] < dist_to_medoid[j])
		dist_to_medoid[j] = costs[min_next_medoid, j]
	end
end
delete!(non_medoid_points, min_next_medoid)
end

medoids, non_medoid_points
end

function calculateSwapValue(costs, medoids::Set{Int}, non_medoids::Set{Int}, old_medoid, new_medoid)
	nf, nc = size(costs)

	delta = 0
	for city in 1:nc
		m = collect(medoids)[indmin(map(i -> costs[i, city], collect(medoids)))]
		curr_cost = costs[m, city]
	if costs[new_medoid, city] < curr_cost # new medoid is closer to city
		delta += costs[new_medoid, city] - curr_cost
	elseif old_medoid == m # city's medoid is removed, must reassign city
	    updated_medoids_arr = filter(i -> in(i, medoids) && i != m, [1:nf]) # medoids - m
	    second_closest_medoid = updated_medoids_arr[indmin(map(i -> costs[i, city], updated_medoids_arr))]
	    delta += min(costs[new_medoid, city], costs[second_closest_medoid, city]) - curr_cost
	end
end

delta
end

function swap_multitiming(costs, orig_medoids::Set{Int}, orig_non_medoids::Set{Int}, P::Int, runtime)
	startTime = time()
	while true
		best_swap = [], [], typemax(Float64)
		for p = 1:P
			for medoid_set in combinations(collect(orig_medoids), p)
				for new_medoid_set in combinations(collect(orig_non_medoids), p)
					if time() - startTime > runtime
						return orig_medoids
					end
					medoids = deepcopy(orig_medoids)
					non_medoids = deepcopy(orig_non_medoids)
					swap_value = 0
					for i = 1:p
						swap_value += calculateSwapValue(costs, medoids, non_medoids, medoid_set[i], new_medoid_set[i])
						delete!(medoids, medoid_set[i])
						push!(non_medoids, medoid_set[i])
						delete!(non_medoids, new_medoid_set[i])
						push!(medoids, new_medoid_set[i])
					end
					if swap_value < best_swap[3]
						best_swap = medoid_set, new_medoid_set, swap_value
					end
				end
			end
		end

		medoid_set, new_medoid_set, delta = best_swap

		if delta < 0
			for i in 1:length(medoid_set)
				delete!(orig_medoids, medoid_set[i])
				push!(orig_non_medoids, medoid_set[i])
				delete!(orig_non_medoids, new_medoid_set[i])
				push!(orig_medoids, new_medoid_set[i])
			end
		else
			break
		end
	end
	orig_medoids
end
