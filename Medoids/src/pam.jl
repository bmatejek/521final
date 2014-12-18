# K-medoids implementation based on the commonly used PAM algorithm (Kaufman's original algorithm)

function pam{T<:Real}(costs::DenseMatrix{T}, k::Integer)
    # check arguments
    n = size(costs, 1)
    size(costs, 2) == n || error("costs must be a square matrix.")
    k <= n || error("Number of medoids should be less than n.")

    build(costs, k)
end

# BUILD phase
# consider: throughout this process, it might actually be cleaner to store the medoids and do a lookup... 
# rather than storing the values!
function build(costs, k)
    n = size(costs, 1)

	medoids = Int[] # CONSIDER: storing these in a set too
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
	cluster_distances = Dict()
	for i = 1:n
		cluster_distances[i] = costs[first_medoid,i] # at first, every object's medoid is the only chosen medoid
	end

	while (length(medoids) < k)
		min_next_medoid = -1
		max_delta = typemin(Float64)
		for i = 1:n # try all possible next medoids
			if !in(i, medoids)
				# consider making i the next medoid
				delta = 0
				for j in 1:n
					if cluster_distances[j] > costs[i,j] # j would be switched to i's cluster; could change this to max w/ 0
						delta += cluster_distances[j] - costs[i,j]
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
			if (costs[i,min_next_medoid] < cluster_distances[i])
				cluster_distances[i] = costs[i,min_next_medoid]
			end
		end
		delete!(non_medoid_points, min_next_medoid) # if i keep this, i can adjust the check above... by examining non_medoid_points
	end
	# this should build k medoids

	# return initialization (k indices -- representing k medoids)
	medoids
end

# SWAP phase
# consider all pairs of objects (i, h) for which object i is a medoid and h is not
# determine effect on objective function when i is no longer a medoid and h is
function swap()
	while true

		best_swap = -1, -1, typemax(Float64)
		for medoid in medoids
			for point in non_medoid_points
				# consider swapping point with a current medoid
				# see what benefit this would produce
				swap_value = 0
				for j in non_medoid_points
					c # INITIALIZE THIS!
					if cluster_distances[j] < costs[j, medoid] && cluster_distances[j] < costs[j, point]
						c = 0
					elseif cluster_distances[j] == costs[j, medoid] # what happens when j loses its medoid
						second_closest_medoid = -1
						min_cost = typemax(Float64)
						for other_medoid in medoids # find second closest representative object
							if other_medoid != i
								if (costs[j, other_medoid] < min_cost)
									second_closest_medoid = other_medoid
									min_cost = costs[j, other_medoid] # FINISH THIS!!!
								end
							end
						end
						# second closest medoid is now correct
						# two possibilities: j is closer to "point" than to the second_closest_medoid
							# in this case: c = costs[j, point] - cluster_distances[j]
						# otherwise, j is farther from "point" than the second_closest_medoid
							# in this case: c = costs[j, second_closest_medoid] - cluster_distances[j]
					elseif cluster_distances[j] > costs[j, point] # part c
						c = costs[j, point] - cluster_distances[j]
					end

					swap_value += c
					_, _, best_val = best_swap
					if swap_value < best_val
						best_swap = medoid, point, swap_value
					end
				end
			end
		end
		old_m, new_m, delta = best_swap
		if delta < 0
			delete!(medoids, old_m)
			push!(non_medoid_points, old_m)
			delete!(non_medoid_points, new_m)
			push!(medoids, new_m)

		end

	end

	medoids
end


