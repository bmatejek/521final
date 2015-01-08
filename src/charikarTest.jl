using Medoids
using Distances

R = [1.0, 1.5, 4.0, Inf];
avgs = Array(Float64, length(R));
for i=1:length(R)
    avgs[i] = 0;
end
nruns = 1;

maxn = 10;
for i=1:nruns;
    println("============================================");
    println("Run $i");
    println("============================================");
    #n = rand(1:maxn);
    #k = rand(1:iround(n/2));
    #d = rand(5:10);
    
    n = 10;
    k = 4;
    d = 5;

    X = 10 * rand(d, n);
    costs = pairwise(SqEuclidean(), X);
    #
    #results = Float64[]
    #println("Finding $(k) medoids...");
    #println("--------------------------------------------");
    #for i=1:length(R)
    #    println("--------------------------------------------");
    #    println("R: $(R[i])");
    #    medoids = charikar2012Variable(costs, k, R[i]);
    #    cost = calculateCost(costs, medoids);
    #    @printf "Cost: %6f\n" cost;
    #    avgs[i] += cost;
    #end

    medoids = charikar2012(costs, k);
    cost = calculateCost(costs, medoids);
    @printf "Cost: %6f\n" cost;   
end
#
#for i=1:length(R)
#    println("R: $(R[i])");
#    println(avgs[i] / nruns);
#end
