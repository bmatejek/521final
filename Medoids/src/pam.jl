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
	medoids, non_medoid_points, dist_to_medoid
end

# SWAP phase
# consider all pairs of objects (i, h) for which object i is a medoid and h is not
# determine effect on objective function when i is no longer a medoid and h is
function swap(costs, medoids::Set{Int}, non_medoids::Set{Int}, dist_to_medoid)
	# consider storing closest medoids instead of distances... and just do a lookup instead!

	while true

		best_swap = -1, -1, typemax(Float64)

		for old_m in medoids
			for new_m in non_medoids
				# consider swapping point with a current old_m; see what benefit this would produce
				swap_value = 0
				for j in non_medoids
					c = 0
					#if dist_to_medoid[j] < costs[j, old_m] && dist_to_medoid[j] < costs[j, point]
						#c = 0

					# find the medoid of j! HEREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
					medoids_arr = collect(medoids)
					m = medoids_arr[indmin(map(i -> costs[i,j], medoids_arr))] # find j's closest medoid

					if old_m == m # j loses its medoid
						medoids_arr = collect(delete!(medoids, m)) # medoids - m
						next_closest_m = medoids_arr[indmin(map(i -> costs[i,j], medoids_arr))]

						if costs[j, new_m] < costs[j, next_closest_m]
							c = costs[j, new_m] - dist_to_medoid[j]
						else
							c = costs[j, next_closest_m] - dist_to_medoid[j]
						end
						# two possibilities: j is closer to "point" than to the second_closest_medoid
							# in this case: c = costs[j, point] - dist_to_medoid[j]
						# otherwise, j is farther from "point" than the second_closest_medoid
							# in this case: c = costs[j, second_closest_medoid] - dist_to_medoid[j]
					elseif costs[j, old_m] > dist_to_medoid[j] > costs[j, new_m] # part c
						c = costs[j, new_m] - dist_to_medoid[j]
					end


					# TRY THIS INSTEAD
					c = 0
					if costs[j, new_m] < dist_to_medoid[j] # new medoid is closer to j
						c = costs[j, new_m] - dist_to_medoid[j]
					elseif old_m == m # j's medoid is removed, must reassign j
						medoids_arr = collect(delete!(medoids, m)) # medoids - m
						next_closest_m = medoids_arr[indmin(map(i -> costs[i,j], medoids_arr))]
						c = min(costs[j, new_m], costs[j, next_closest_m]) - dist_to_medoid[j]
					end




					# j's current medoid is better





					swap_value += c

				end

				# ADD to swap_value: removed old_m's contribution

				removed_medoid_closest_medoid = -1
				min_dist = typemax(Float64)
				for m in medoids
					if m != old_m && costs[old_m, m] < min_dist
						removed_medoid_closest_medoid = m
						min_dist = costs[old_m, m]
					end
				end

				if costs[point, old_m] < min_dist
					min_dist = costs[point, old_m]
				end

				swap_value += min_dist

				# also subtract the contribution of the chosen point? might already be accounted for

				_, _, best_val = best_swap
				if swap_value < best_val
					best_swap = medoid, point, swap_value
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

	end

	medoids
end


