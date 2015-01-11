include("Medoids.jl");
include("utils.jl");

using Medoids

function readFile(filename::String)
    fd = open(filename)
    data = readlines(fd)
    i = 1
    linecount = 0
    for line in data
        line = chomp(line)
        if (linecount == 0)
            k = parseint(line);
        elseif (linecount == 1)
            fc = split(line, " ");
            nf = parseint(fc[1]);
            nc = parseint(fc[2]);
            costs = fill(typemax(Float64, nf, nc));
        else
            costsj = split(line, ",")
            j = 1
            for costj in costsj
                costs[i, j] = parsefloat(costj);
                j += 1
            end
        end
        linecount += 1
        i += 1
    end
    costs, k
end

function testInstanceFile(algorithms, costs, k) 
    results = Float64[];
    for alg in algorithms
        medoids = alg(costs, k);
        cost = calculateCost(costs, medoids);
        push!(results, cost);
    end
    results
end

algs = [Medoids.charikar2012];
names = ["charikar2012"];

for i=1:instances
    costs, k = readFile("./data/costs/");
    val = Medoids.testInstance(algs, costs, k);
    println(val);
end
