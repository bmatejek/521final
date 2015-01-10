using DataStructures

DEBUG = false

function connectCity(costs, cityId, facId, contributing, facilityTimes, contribCounts, cityConnectTime, currTime, handles, predCompletionTimes)
	nf = size(costs, 1)
	DEBUG && println("Connecting $(cityId) to $(facId)")
	for i in 1:nf
		if i != facId && contributing[i, cityId]
			if contribCounts[i] == 1
				facilityTimes[2, i] = facilityTimes[1, i] - currTime
				facilityTimes[1, i] = Inf
				DEBUG && println("$(i) has no cities left: $(facilityTimes[:, i])")
			else
				facilityTimes[1, i] = currTime + (facilityTimes[1, i] - currTime) * contribCounts[i]/(contribCounts[i]-1)
			end
			contribCounts[i] -= 1
			update!(predCompletionTimes, handles[i], (facilityTimes[1, i], i))
			contributing[i, cityId] = false
		end
	end
	cityConnectTime[cityId] = currTime
end


function phase1{T<:Real}(costs::DenseMatrix{T}, facilityCost)
	nf, nc = size(costs)
	a = zeros(nc) # set a[j] to -1 if it's no longer increasing -- city j is connected?
	contributing = fill(false, nf, nc) # [i, j]: Are facility i, city j connected?
	isFacilityOpen = fill(false, nf)
  facOpenOrder = Int[]
	cityConnectTime = fill(Inf, nc)
	contribCounts = zeros(nf)  # number of cities currently contributing to facility i
	facilityTimes = zeros(2, nf) # Predicted completion time

	edgesByCost = (Float64, Int, Int)[]
	DEBUG && println("nf: $(nf), nc: $(nc)")
	for i = 1:nf
		for j = 1:nc
			push!(edgesByCost, (costs[i,j], i, j))
		end
	end
	sort!(edgesByCost)
	DEBUG && println(edgesByCost)

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
		DEBUG && println("Processing $(edge)")
		t, i, j = edge # i is the facility and j is the city

    # Facility opened between previous time and now
		while (length(predCompletionTimes) > 0 && top(predCompletionTimes)[1] <= t)
			cTime, f = pop!(predCompletionTimes)  # WHY DOES THIS CAUSE PROBLEMS WITH COST = 0?!?
			isFacilityOpen[f] = true
      push!(facOpenOrder, f)
			for c = 1:nc
				if contributing[f, c]
					numConnectedCities += 1
					connectCity(costs, c, f, contributing, facilityTimes,
						contribCounts, cityConnectTime, cTime, handles,
						predCompletionTimes)
				end
			end
		end
		# Make sure this city is still unconnected
		if cityConnectTime[j] <= t # if this city is connected, a[j] would not have increased during this time
			continue
		end

		# else it's not connected, so a[j] increased and the edge became tight

		if !isFacilityOpen[i]
			# if it was previously infinity, handle this case separately

			#= The amount contributed towards its cost at the current time can be easily computed. 
			What does this mean? Why would it contribute anything other than 0 at this point? =#

			DEBUG && println("City $(j) contributing to $(i) at $(t)")
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
			numConnectedCities += 1
			connectCity(costs, j, i, contributing, facilityTimes,
				contribCounts, cityConnectTime, t, handles,
				predCompletionTimes)
		end

		if numConnectedCities == nc # is this right?
			break
		end
	end

	while (numConnectedCities < nc)
    assert(length(predCompletionTimes) > 0)
		cTime, f = pop!(predCompletionTimes)
		DEBUG && println("Cleanup: $(f) open at $(cTime)")
		isFacilityOpen[f] = true
    push!(facOpenOrder, f)
		for c = 1:nc
			if contributing[f, c]
				numConnectedCities += 1
				connectCity(costs, c, f, contributing, facilityTimes,
					contribCounts, cityConnectTime, cTime, handles,
					predCompletionTimes)
			end
		end
	end

  (cityConnectTime, facOpenOrder)
end


#phase1([1 1], 2)
#phase1([1; 1], 2)
#phase1(a, 0)
#phase1(transpose(a), 1)
#phase1(rand(5,10), 2)


#phase1(transpose(a), 2)

function phase2(costs, cityConnectTime, facOpenOrder)
	nf, nc = size(costs)

  # T is the subgraph of special edges on the original graph
  T = fill(0, nf + nc, nf + nc)
  for city = 1:nc
      facIds = Int[]
      for fac = 1:nf
          if costs[fac, city] < cityConnectTime[city]
             push!(facIds, fac)
          end
      end
      T[facIds, nf + city] = 1
      T[nf + city, facIds] = 1
  end
  # Is there a path of at most length 2 between i and j in T?
  T2 = T + T * T
  T2[find(T2)] = 1

  #openFacIds = sort(facOpenOrder)
  #H = T2[openFacIds, openFacIds]
  H = T2[facOpenOrder, facOpenOrder]

  DEBUG && println(facOpenOrder)
  DEBUG && println(T2)
  DEBUG && println(H)
  # Maximal independent set of facilities
  I = Int[]
  IndexSet = Int[]  # Keep the mapped IDs for use in indexing
  for (i, f) in enumerate(facOpenOrder)
      # Add facility to set if it is not adjacent to any already picked facility
      if !any(H[IndexSet, i] .== 1)
         push!(I, f)
         push!(IndexSet, i)
      end
  end
  I
end

function jv_cost(costs, cost)
    cityConTimes, facOpenOrder = phase1(costs, cost)
    openFacs = phase2(costs, cityConTimes, facOpenOrder)
end

function jv(costs, k)
    low = 0
    cost = 0
    while length(jv_cost(costs, cost)) > k
        if cost == 0
            cost = 1
        else
            low = cost
            cost *= 2
        end
    end
    high = cost
    maxIter = 50  # Hard coded maximum on search iterations for now
    iter = 0
    while iter < maxIter && low <= high
        println(iter)
        iter += 1
        mid = (low+high)/2
        facilities = jv_cost(costs, mid)
        v = length(facilities)
        if v == k
            return facilities
        elseif v > k 
          low = mid
        else v < k 
          high = mid
        end
    end
    return Int[]
end

#phase2([3 1], [2 3], [true])

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



