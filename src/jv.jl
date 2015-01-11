using DataStructures



t = 1 # for now?

# use a Set

# facilityCost 
function phase1{T<:Real}(costs::DenseMatrix{T}, facilityCost)
	n = size(costs, 1)
	a = zeros(n)
	b = zeros(n, n)

	times = unique(sort(costs[:])) # How time advances
	edgesByCost = 
	for i = 1:n
		for j = i:n

		end
	end
	contribCounts = zeros(n)  # number of cities contributing to facility
	predCompletion = binary_minheap(fill(Inf, n)) # Predicted time when facility i is completed

	for time in times

	end


	# possible store tight 

end

function phase2
end

function rounding
end


#= Algorithm:
1. Sort all the edges by increasing cost -- this gives the order and times at which edges go tight.
However, note that some of these edges might not go tight: once a client is connected, a[j] stops going up, so this client
will never reach facilities farther away (those edges will never go tight).



