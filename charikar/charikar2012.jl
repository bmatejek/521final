module Charikar2012

###############################################################
## Needed packages
###############################################################

using Clp
using JuMP

###############################################################
## Initialization of problem variables
###############################################################

DEBUG = true;

# point data structure used for all facilities and clients
type DataPoint
	coordinates
end

# return the manhattan distance between DataPoints a and b
function manhattandistance(xi::DataPoint, xj::DataPoint)
	size(xi.coordinates) == size(xj.coordinates) || error("$xi and $xj must have the same dimension for L1 distances")
	sum(abs(xi.coordinates - xj.coordinates))	
end

# return the euclidean distance between DataPoints a and b
function euclideandistance(xi::DataPoint, xj::DataPoint)
	size(xi.coordinates) == size(xj.coordinates) || error("$a and $b must have the same dimension for L2 distances")
	sqrt(sum((xi.coordinates - xj.coordinates) .^ 2))
end

n = 3			# n is the number of points
k = 2			# k is the number of cluster centers

x1 = DataPoint([8 3 4])
x2 = DataPoint([1 5 9])
x3 = DataPoint([6 7 2])

X = [1=>x1, 2=>x2, 3=>x3];

# for the k-medians problem, F = C = X, deepcopy used to protect elements
F = deepcopy(X)
C = deepcopy(X)

# create the original n x n distance matrix
# for d_ij, i is the facility and j is the client
d = zeros(Float64, (length(F), length(C)));
for i=1:length(F)
	for j=1:length(C)
		d[i, j] = euclideandistance(get(F, i, DataPoint(0)), get(C, j, DataPoint(0)))
	end
end

# Print the LP variables
if (DEBUG)
	println("\n#################################################");
	print("Initialized Variables");
	println("\n#################################################\n");
	println("X: \n");
	for key in sort(collect(keys(X)))
		println("$key $(X[key])\n");
	end
	println("F: \n");
	for key in sort(collect(keys(F)))
		println("$key $(F[key])\n");
	end
	println("C: \n");
	for key in sort(collect(keys(C)))
		println("$key $(C[key])\n");
	end
	for x=1:size(d,1)
		if (x == 1)
			print("d:\t");
			for y=1:size(d, 2)
				@printf "%d\t\t" y;
			end		
			println();
		end
		print("$x\t");
		for y=1:size(d,2)
			@printf "%6f\t" d[x, y];
		end
		println();
	end
end

###############################################################
## Solving the LP
###############################################################

# solver = GurobiSolver()
m = Model()

# define variables x and y, must all be between 0 and 1
# x_ij is the fractional amount of client j that used facility i
@defVar(m, 0 <= x[1:length(F), 1:length(C)] <= 1)
# y_i is the fractional amount of facility at location y_i
@defVar(m, 0 <= y[1:length(F)] <= 1)				

# add in the constraints
# for every client in C, the sum of the fractional facility use over F must equal 1
for j in 1:length(C)
	@addConstraint(m, sum{x[i, j], i=1:length(F)} == 1)
end

# for each facility, the fractional use by any client cannot exceed the fractional availability of the facility
for i in 1:length(F)
	for j in 1:length(C)
		@addConstraint(m, x[i, j] <= y[i])
	end
end

# the fractional sum of all facility availability cannot exceed k
@addConstraint(m, sum{y[i], i=1:length(F)} <= k)

# set the objective as minimizing the total cost for each client over the facilities they fractionally use
@setObjective(m, Min, sum{d[i, j] * x[i, j], i=1:length(F), j=1:length(C)})
solve(m)

x = getValue(x)
y = getValue(y)

if (DEBUG)
	println("\n#################################################");
	print("LP Solution");
	println("\n#################################################\n");
	for i=1:size(x,1)
		if (i == 1)
			print("x:\t");
			for j=1:size(d, 2)
				@printf "%d\t\t" j;
			end		
			println();
		end
		print("$i\t");
		for j=1:size(x,2)
			@printf "%6f\t" x[i, j];
		end
		println("\n");
	end
	for i=1:size(y, 1)
		println("y[$i] = $(y[i])");
	end
end

###############################################################
## Preliminary variables for rounding scheme
###############################################################

# remove all facilities i from C with y_i = 0
for i in keys(C)
	if (y[i] == 0.0) 
		delete!(C, i);
	end
end

# define a new set of F set variables denoted as F_j
# the elements in F_j are determined by all of the possible facilities i such that
# x_ij > 0 - interpret this as the set of facilities that j has a non zero probability of belonging to
F_ = Dict{Int32, Dict{Int32, DataPoint}}();
for j in keys(C)
	Fj = Dict{Int32, DataPoint}();
	for i in keys(F)
		if (x[i, j] > 0.0) 
			get!(Fj, i, F[i]);
		end
	end
	get!(F_, j, Fj);
end

# F_ is just a temporary variable, reassign F to another variable name
xF = deepcopy(F);
F = deepcopy(F_);

# define a volumne function for any variable F' in F that is the sum of y_i in F'
function vol(Fp::Dict{Int32, DataPoint})
	sum = 0;
	for i in keys(Fp)
		sum = sum + y[i];
	end
	return sum;
end

# this is the average distance from j to F'
function dist(j::Int32, Fp::Dict{Int32, DataPoint}) 
	sum = 0;
	for i in keys(Fp)
		sum += y[i] * d[j, i];
	end
	return sum / vol(Fp);
end

# the connection cost of j in the fractional solution
function dav(j::Int32)
	sum = 0;
	for i in keys(F[j])
		sum += y[i] * d[i, j];
	end
	return sum;
end

# the set of facilities that have a distance strictly smaller than r to j
function B(j::Int32, r::Float64)
	Bjr = Dict{Int32, DataPoint}();
	for i in keys(F)
		if (d[i, j] < r)
			get!(Bjr, i, xF[i]);
		end
	end
	return Bjr;
end

if (DEBUG)
	println("\n#################################################");
	print("Preliminary variables for rounding scheme");
	println("\n#################################################\n");
	println("C: \n");
	for key in sort(collect(keys(C)))
		println("$key $(C[key])\n");
	end
	println("F: \n");
	for key in sort(collect(keys(F)))
		println("F[$key]:");
		for keyp in sort(collect(keys(F[key])))
			println("$keyp $((F[key])[keyp])\n");
		end
	end

	println("All these volumes should be 1.0");
	for key in sort(collect(keys(F)))
		println("vol(F[$key]): $(vol(F[key]))");
		if (vol(F[key]) != 1.0)
			println("Error");
			return;
		end
	end

	println("\nConnection cost of j in the fractional solution");
	for key in sort(collect(keys(F)))
		println("dav($key) = $(dav(key))");
	end
	println("\nThe set of facilities whose distance to j is less than 10.0");
	for j in sort(collect(keys(C)))
		Bj = B(j, 10.0);
		println("$j:");
		for i in sort(collect(keys(Bj)))
			@printf "%d %6f\n" i (d[i, j]);
			if (d[i, j] > 10.0) 
				println("Error");
				return;
			end
		end
		println();
	end
end

###############################################################
## Filtering Phase
###############################################################

Cp = Dict{Int32, DataPoint}();
Cpp = deepcopy(C);

# get all of the average dictionary elements
DAV = Dict{Int32, Float64}();
for i in keys(C)
	davVal = dav(i);
	if (i == 2) davVal = 1.0; end;
	get!(DAV, i, davVal);
end
println(DAV);

for j in sort(collect(keys(DAV)))
	# only consider j still in C''
	if (get(Cpp, j, 0) != 0)
		# add j to C'
		get!(Cp, j, Cpp[j]);
		for jp in keys(Cpp)
			if (d[j, jp] <= 4 * dav(jp))
				delete!(Cpp, jp);
			end
		end
	end
	# delete j from C''
	delete!(Cpp, j);
end

if (DEBUG)
	println("\n#################################################");
	print("Filtering Phase");
	println("\n#################################################\n");
	println("C': \n");
	for key in sort(collect(keys(Cp)))
		println("$key $(Cp[key])\n");
	end
	println("\nC'' should be null");
	println("C'': \n");
	for key in sort(collect(keys(Cpp)))
		println("$key $(Cpp[key])\n");
	end
	if (length(Cpp) != 0)
		println("Error\n");
		return;
	end
end

###############################################################
## Bundling Phase
###############################################################

# each client j in C' should be assigned a set of facilities in large volume
U = Dict{Int32, Dict{Int32, DataPoint}}();
for j in keys(Cp)
	get!(U, j, Dict{Int32, DataPoint}());
end

# R is half the distance of j to its nearest neighbor in C'
R = Dict{Int32, Float64}();
for j in keys(Cp)
	min = typemax(Float64);
	for jp in keys(Cp)
		if (j == jp) continue; end;
		if (d[j, jp] < min)
			min = d[j, jp];
		end
	end
	get!(R, j, 0.5 * min);
end

# get Fj' for each j in Cp
Fp = Dict{Int32, Dict{Int32, DataPoint}}();
FAll = Dict{Int32, DataPoint}();
for j in keys(Cp)
	Fj = get(F, j, 0);
	if (Fj == 0) println("Error, F[$j] does not exist\n"); return; end
	Bj = B(j, 1.5 * get(R, j, 0));
	# find the intersection between these two sets Fj and Bj
	Fpj = Dict{Int32, DataPoint}();
	for i in keys(Fj)
		if (get(Bj, i, 0) != 0)
			get!(Fpj, i, get(Bj, i, 0));
			get!(FAll, i, get(Bj, i, 0));
		end
	end
	# add this intersection to F'
	get!(Fp, j, Fpj);
end

# go through all facilities to see if they belong to a F'
FAllDist = Array(Float64, length(xF));
FAllClosest = Array(Array{Int32}, length(xF));
for i=1:length(xF)
	FAllDist[i] = typemax(Float64);
	FAllClosest[i] = Array(Int32, 0);
	if (get(FAll, i, 0) == 0) continue; end
	# go through all clients in Cp
	for j in keys(Cp)
		Fpj = Fp[j];
		if (get(Fpj, i, 0) == 0) continue; end;
		if (d[i, j] > FAllDist[i]) continue; end;
		FAllDist[i] = d[i, j];
		FAllClosest[i] = vcat(FAllClosest[i], j);
	end
end

# add the FAllClosest
for i=1:length(xF)
	if (length(FAllClosest[i]) == 0) continue; end;
	closest = FAllClosest[i][rand(1:length(FAllClosest[i]))];
	Uj = get(U, closest, 0);
	if (Uj == 0) println("Error, j not in C'\n"); return; end;
	get!(Uj, i, xF[i]);
end

if (true)
	println("\n#################################################");
	print("Bundling Phase");
	println("\n#################################################\n");
	println("R': \n");
	for key in sort(collect(keys(R)))
		@printf "%d %6f\n" key R[key];
	end
	println("\nF': \n")
	for key in sort(collect(keys(Fp)))
		println("F'[$key]:");
		Fpj = Fp[key];
		for keyp in sort(collect(keys(Fpj)))
			println("$keyp $(Fpj[keyp])\n");
		end
	end
	println("\nThis list should include all of the facilities in F'");
	for key in sort(collect(keys(FAll)))
		println("$key $(FAll[key])")
	end
	println("\nList of closest facilities to those in F'");
	for i=1:length(FAllDist)
		@printf "%d\t%6f:" i FAllDist[i];
		for j=1:length(FAllClosest[i])
			print("\t$j,")
		end
		println();
	end
	println("\nU: \n");
	for j in sort(collect(keys(U)))
		println("U[$j]: ");
		Uj = get(U, j, 0);
		for key in sort(collect(keys(Uj)))
			println("$key $(Uj[key])");
		end
	end
	## make sure that all of the volumes of Uj are between 0.5 and 1.0
	println("\nConfirming volumes of Uj ...");
	for j in sort(collect(keys(U)))
		if (vol(U[j]) < 0.5 || vol(U[j]) > 1.0) println("Error: vol(U[$j]) violates assumption"); return; end;
	end
	println("Confirmed.\n");
end

###############################################################
## Matching Phase
###############################################################

type Match
	j
	jp
	d
end

pairs = (length(Cp) * (length(Cp) - 1)) / 2;
Mp = Array(Match, iround(pairs));
count = 1;
for j=1:length(Cp)
	for jp=j:length(Cp)
		if (j == jp) continue; end;
		Mjjp = Match(j, jp, d[j, jp]);
		Mp[count] = Mjjp;
		count += 1;
	end
end

# custom sort function for Matches
function MSort(a::Match, b::Match)
	if (a.d < b.d) return true;
	else return false; end;
end

sort!(Mp, lt=MSort, alg=QuickSort);

# make sure everything is only in one match
matched = Array(Bool, length(Cp))
for i=1:length(matched)
	matched[i] = false;
end

M = Dict{Int32, Match}();
count = 0;
for i=1:length(Mp)
	j = Mp[i].j;
	jp = Mp[i].jp;
	if (matched[j] || matched[jp]) continue; end;
	matched[j] = true;
	matched[jp] = true;
	get!(M, count, Mp[i]);
	count += 1;
end

# see if there is anything left out of M
for i=1:length(matched)
	if (!matched[i])
		M1 = Match(i, 0, 0);
		get!(M, count + 1, M1);
	end
end

if (true)
	println("\n#################################################");
	print("Matching Phase");
	println("\n#################################################\n");
	println("M:\n");
	for key in sort(collect(keys(M)))
		Mp = M[key];
		if (Mp.jp == 0)
			@printf "%d" Mp.j;
		else
			@printf "%d\t%d\t%6f\n" Mp.j Mp.jp Mp.d;
		end
	end
end

###############################################################
## Sampling Phase
###############################################################

# Create list of empty facilities
kOpen = Array(Bool, length(xF));
for i=1:length(xF)
	kOpen[i] = false;
end

for key in sort(collect(keys(M)))
	Mp = M[key];
	j = Mp.j;
	jp = Mp.jp;
	if (Mp.jp != 0) 
		if (get(U, j, 0) == 0) println("Error, $j not in U"); return; end;
		if (get(U, jp, 0) == 0) println("Error, $jp not in U"); return; end;

		volUj = vol(U[j]);
		volUjp = vol(U[jp]);

		rnd = rand();
		if (rnd < 1 - volUjp) kOpen[j] = true;
		elseif (rnd < (1 - volUjp) + (1 - volUj)) kOpen[jp] = true;
		else
			kOpen[j] = true;
			kOpen[jp] = true;
		end
	else
		rnd = rand();
		if (get(U, j, 0) == 0) println("Error, $j not in U"); return; end;
		if (rnd < vol(U[j]))
			kOpen[j] = true;
		end
	end
end

# for each facility not in bundle, open independently with probability yi
for i=1:length(xF)
	if (length(FAllClosest[i]) != 0) continue; end;
	rnd = rand();
	if (rnd < y[i])
		kOpen[i] = true;
	end
end

if (true)
	println("\n#################################################");
	print("Sampling Phase");
	println("\n#################################################\n");
	println("k open facilities:");
	for i=1:length(kOpen)
		if (kOpen[i])
			println("$i $(xF[i])");
		end
	end
end

# end the module
end

# use the module created above
using Charikar2012