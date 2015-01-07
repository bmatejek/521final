using Medoids

R = [1.0, 1.5, 4.0, Inf];
avgs = Array(Float64, length(Rs));
for i=1:length(R)
    avgs[i] = 0;
end
nruns = 1000;

maxn = 1000;
for i=1:nruns;
    n = rand(1:maxn);
    k = rand(1:Int32(n/2));
    println(n);
println(k);
    _, costs = Medoids.randomInstance(d, n);

    results = Float64[]
    println("Finding $(k) medoids...");
    println("--------------------------------------------");
    for i=1:length(R)
        println("---------------------------------------------");
        println("R: $R");
        results = Float64[];
        tic();
        medoids = charikar2012Variable(costs, k, R[i]);
        toc();
        cost = calculateCost(costs, medoids);
        avgs[i] += cost;
        println("Medoids: $(medoids)");
        println("Total cost: $(cost)");
    end
end

for i=1:length(R)
    println("R: $(R[i])");
    println(avgs[i] / nruns);
end