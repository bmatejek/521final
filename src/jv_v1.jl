using DataStructures

function connectCity(costs, cityId, facId, contributing, facilityTimes, contribCounts, isCityConnected, currTime, handles, predCompletionTimes)
	nf = size(costs, 1)
	println("Connecting $(cityId) to $(facId)")
	for i in 1:nf
		if i != facId && contributing[i, cityId]
			if contribCounts[i] == 1
				facilityTimes[2, i] = facilityTimes[1, i] - currTime
				facilityTimes[1, i] = Inf
				println("$(i) has no cities left: $(facilityTimes[:, i])")
			else
				facilityTimes[1, i] = currTime + (facilityTimes[1, i] - currTime) * contribCounts[i]/(contribCounts[i]-1)
			end
			contribCounts[i] -= 1
			update!(predCompletionTimes, handles[i], (facilityTimes[1, i], i))
			contributing[i, cityId] = false
		end
	end
	isCityConnected[cityId] = true  # <--- Change to TIME
end


function phase1{T<:Real}(costs::DenseMatrix{T}, facilityCost)
	nf, nc = size(costs)
	a = zeros(nc) # set a[j] to -1 if it's no longer increasing -- city j is connected?
	contributing = fill(false, nf, nc) # [i, j]: Are facility i, city j connected?
	isFacilityOpen = fill(false, nf)
	isCityConnected = fill(false, nc)
	contribCounts = zeros(nf)  # number of cities currently contributing to facility i
	facilityTimes = zeros(2, nf) # Predicted completion time

	edgesByCost = (Float64, Int, Int)[]
	println("nf: $(nf), nc: $(nc)")
	for i = 1:nf
		for j = 1:nc
			push!(edgesByCost, (costs[i,j], i, j))
		end
	end
	sort!(edgesByCost)
	println(edgesByCost)

	handles = Int[]
	predCompletionTimes = mutable_binary_minheap((Float64, Int))
	for i = 1:nf
		push!(handles, push!(predCompletionTimes, (Inf, i)))
		facilityTimes[1, i] = Inf
		facilityTimes[2, i] = facilityCost
	end

	# Predicted time when facility i would be paid for if no other event were to happen along the way
	# I think this just means: if no other cities became connected (i.e., all a-values continued to increase)

	# might have to store the handles in an array and access them that way


	# break out of this loop when all cities are connected?
	numConnectedCities = 0
	for edge in edgesByCost
		println("Processing $(edge)")
		t, i, j = edge # i is the facility and j is the city

		# HERE!!! see what happens if facility i is completely paid for between the prev time and now
		# is this ok -- will we address all facilities properly?
		while (top(predCompletionTimes)[1] <= t)
			println(top(predCompletionTimes))
			cTime, f = pop!(predCompletionTimes)  # WHY DOES THIS CAUSE PROBLEMS WITH COST = 0?!?
			println("Opening facility $(f) at $(cTime)")
			isFacilityOpen[f] = true  # <--- Use time later?
			for c = 1:nc
				if contributing[f, c]
					numConnectedCities += 1
					connectCity(costs, c, f, contributing, facilityTimes,
						contribCounts, isCityConnected, cTime, handles,
						predCompletionTimes)
				end
			end
		end

		# Make sure this city is still unconnected
		if isCityConnected[j] # if this city is connected, a[j] would not have increased during this time
			continue
		end

		# else it's not connected, so a[j] increased and the edge became tight

		if !isFacilityOpen[i]
			# if it was previously infinity, handle this case separately

			#= The amount contributed towards its cost at the current time can be easily computed. 
			What does this mean? Why would it contribute anything other than 0 at this point? =#

			println("City $(j) contributing to $(i) at $(t)")
			if contribCounts[i] == 0
				newTime = t + facilityTimes[2, i]
			else
				newTime = t + (facilityTimes[1, i] - t) * contribCounts[i]/(contribCounts[i]+1)
			end
			contribCounts[i] += 1
			contributing[i, j] = true
			update!(predCompletionTimes, handles[i], (newTime, i))
			facilityTimes[1, i] = newTime
		else # facility i is already open
			isCityConnected[j] = true
			numConnectedCities += 1
			connectCity(costs, j, i, contributing, facilityTimes,
				contribCounts, isCityConnected, t, handles,
				predCompletionTimes)
		end

		if numConnectedCities == nc # is this right?
			break
		end
	end



	while (numConnectedCities < nc)
		cTime, f = pop!(predCompletionTimes)
		println("Cleanup: $(f) open at $(cTime)")
		isFacilityOpen[f] = true  # <--- Use time later? TODO
		for c = 1:nc
			if contributing[f, c]
				numConnectedCities += 1
				connectCity(costs, c, f, contributing, facilityTimes,
					contribCounts, isCityConnected, cTime, handles,
					predCompletionTimes)
			end
		end
	end


	# TODO: Store tight edges, opening order
end

a = zeros(2, 1)
a[1, 1] = 1
a[2, 1] = 1
#phase1(a, 2)
#phase1(transpose(a), 2)
#phase1(a, 0)
phase1(transpose(a), 1)
#phase1(rand(5,10), 2)


#phase1(transpose(a), 2)

function phase2()
end

function rounding()
end


#= Algorithm:
1. Sort all the edges by increasing cost -- this gives the order and times at which edges go tight.
However, note that some of these edges might not go tight: once a client is connected, a[j] stops going up, so this client
will never reach facilities farther away (those edges will never go tight).

2. When an edge goes tight, why would t_i decrease by more than 0? the edge just went tight, so a_j should be equal to c_ij, 
shouldn't it? this would mean b_ij is still 0.
3. 
=#



