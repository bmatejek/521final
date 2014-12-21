# K-medoids implementation based on the commonly used PAM algorithm (Kaufman's original algorithm)

function pam{T<:Real}(costs::DenseMatrix{T}, k::Integer)
    # check arguments
    n = size(costs, 1)
    size(costs, 2) == n || error("costs must be a square matrix.")
    k <= n || error("Number of medoids should be less than n.")

    println(typeof(swap(costs, build(costs, k)...)))

	collect(swap(costs, build(costs, k)...))
end

# BUILD phase
# consider: throughout this process, it might actually be cleaner to store the medoids and do a lookup... 
# rather than storing the values!
function build{T<:Real}(costs::DenseMatrix{T}, k::Integer)
    n = size(costs, 1)

	medoids = Set{Int}() # CONSIDER: does a set make more sense than an array?
	non_medoid_points = Set(1:n)

	min_cost = typemax(Float64)
	first_medoid = -1
	for i = 1:n
		cost = 0
		for j = 1:n # cost of making i the medoid
			cost += costs[i,j]
		end
		if cost < min_cost
			min_cost = cost
			first_medoid = i
		end
	end

	# ADD: check that first_medoid is not -1
	push!(medoids, first_medoid)
	delete!(non_medoid_points, first_medoid)

	# initialize current cost dictionary
	dist_to_medoid = Dict{Int,Float64}()
	for i = 1:n
		dist_to_medoid[i] = costs[first_medoid,i] # at first, every object's medoid is the only chosen medoid
	end

	while (length(medoids) < k)
		min_next_medoid = -1
		max_delta = typemin(Float64)
		for i = 1:n # try all possible next medoids
			if !in(i, medoids)
				# consider making i the next medoid
				delta = 0
				for j in 1:n
					if dist_to_medoid[j] > costs[i,j] # j would be switched to i's cluster; could change this to max w/ 0
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
		for i in 1:n
			if (costs[i,min_next_medoid] < dist_to_medoid[i])
				dist_to_medoid[i] = costs[i,min_next_medoid]
			end
		end
		delete!(non_medoid_points, min_next_medoid) # if i keep this, i can adjust the check above... by examining non_medoid_points
	end
	# this should build k medoids

	# return initialization (k indices -- representing k medoids)
	medoids, non_medoid_points
end

# helper function for mapping -- TEST THIS!
function compute_medoid_map(costs, medoids::Vector{Int})
	map(i -> medoids_arr[indmin(map(j -> costs[i,j], medoids_arr))], 1:n)
end


# SWAP phase
# consider all pairs of objects (i, h) for which object i is a medoid and h is not
# determine effect on objective function when i is no longer a medoid and h is
function swap(costs, medoids::Set{Int}, non_medoids::Set{Int})
	n = size(costs, 1)
	# medoid_mapping[i] = medoid of point i
	medoids_arr = collect(medoids)
	medoid_mapping = map(i -> medoids_arr[indmin(map(j -> costs[i,j], medoids_arr))], 1:n)

	while true

		best_swap = -1, -1, typemax(Float64)

		for old_m in medoids
			for new_m in non_medoids
				swap_value = 0
				for j in non_medoids # MAKE SURE THE FOLLOWING CODE IS CORRECT!
					m = medoid_mapping[j] # j's medoid
					curr_cost = costs[j, m]
					c = 0
					if costs[j, new_m] < curr_cost # new medoid is closer to j
						c = costs[j, new_m] - curr_cost
					elseif old_m == m # j's medoid is removed, must reassign j
						medoids_arr = collect(delete!(medoids, m)) # medoids - m
						next_closest_m = medoids_arr[indmin(map(i -> costs[i,j], medoids_arr))]
						c = min(costs[j, new_m], costs[j, next_closest_m]) - curr_cost
					end
					swap_value += c
				end

				# add old_m's contribution
				medoids_arr = collect(delete!(medoids, old_m))
				swap_value += min(costs[old_m, new_m], costs[old_m, medoids_arr[indmin(map(i -> costs[i,old_m], medoids_arr))]])
				# CHECK THIS ^ move new_m into medoids_arr

				if swap_value < best_swap[3]
					best_swap = old_m, new_m, swap_value
				end
			end
		end

		old_m, new_m, delta = best_swap

		if delta < 0
			println("here: $(delta), $(medoids), $(old_m), $(non_medoid_points), $(new_m)")
			delete!(medoids, old_m)
			push!(non_medoid_points, old_m)
			delete!(non_medoid_points, new_m)
			push!(medoids, new_m)
		else
			println("STOP")
			break
		end

		# other sanity checks... check that calculateCost in utils function before and after each swap is equal to delta

	end

	medoids
end


