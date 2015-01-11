include("Medoids.jl");
include("utils.jl");

using Medoids

algs = [Medoids.charikar2012];
names = ["charikar2012"];

instances = 40;
performance = Array(Float64, instances);

for i=1:instances
    costs, k, opt = Medoids.loadOrLib("./data/orlib", i);
    val = Medoids.testInstance(algs, costs, k, opt);
    performance[i] = val[1];
end

println(ARGS);
f = open(ARGS[1], "w");

for i=1:length(performance)
    write(f, "$(performance[i])\n");
end
