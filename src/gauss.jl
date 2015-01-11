#using Medoids
using Distances

type DataPoint
    coordinates
end

function euclideandistance(xi::DataPoint, xj::DataPoint)
    return sqrt(sum((xi.coordinates - xj.coordinates) .^2));
end

function manhattandistance(xi::DataPoint, xj::DataPoint)
    return sum(abs(xi.coordinates - xj.coordinates));
end

function readFile(filename::String)
    fd = open(filename);
    data = readlines(fd);
    openingFacilities = false;
    openingClients = false;
    facilities = [];
    clients = [];
    k = 0;
    for line in data
        line = chomp(line);
        if (contains(line, "Facilities"))
            openingFacilities = true;
            openingClients = false;
        elseif (contains(line, "Clients"))
            openingFacilities = false;
            openingClients = true;
        elseif (contains(line, "# group"))
            k += 1;
            openingFacilities = false;
            openingClients = false;
        elseif (openingFacilities)
            strcoordinates = split(line, " ");
            coordinates = Array(Float64, length(strcoordinates));
            for i=1:length(strcoordinates)
                coordinates[i] = parsefloat(strcoordinates[i]);
            end
            facilities = vcat(facilities, DataPoint(coordinates));
        elseif (openingClients)
            strcoordinates = split(line, " ");
            coordinates = Array(Float64, length(strcoordinates) - 1);
            for i=1:length(strcoordinates) - 1
                coordinates[i] = parsefloat(strcoordinates[i]);
            end
            clients = vcat(clients, DataPoint(coordinates));
        end
    end
    if (length(clients) > 1000)
        exit();
    end
    close(fd);
    
    costs = fill(typemax(Float64), length(facilities), length(clients));
    cCosts = fill(typemax(Float64), length(clients), length(clients));
    for i=1:length(facilities)
        for j=1:length(clients)
            costs[i, j] = euclideandistance(facilities[i], clients[j]);
        end
    end
    
    w = 0;
    for i=1:length(clients)
        for j=1:length(clients)
            cCosts[i, j] = euclideandistance(clients[i], clients[j]);
            w += 1;
        end
    end
    costs, cCosts, k
end

costs, cCosts, k = readFile("./data/gauss/constant/constant-10-16-410-29.txt");

println("Number of facilities: $(size(costs, 1))");
println("Number of clients: $(size(costs, 2))");
println("k: $k");

function calculateCost{T<:Real}(costs::DenseMatrix{T}, medoids::Array{Int})
    distances = fill(typemax(Float64), size(costs, 2));
    for m in medoids
        distances = min(distances, transpose(costs[m,:]));
    end
    sum(distances)
end

tic()
medoids = Medoids.charikar2012(costs, k, cCosts);
cost = calculateCost(costs, medoids);
println("Charikar: ", cost);
toc();

tic();
medoids = Medoids.forwardGreedyBrian(costs, k);
cost = calculateCost(costs, medoids);
println("Forward Greedy: ", cost);
toc();

tic()
medoids = Medoids.reverseGreedyBrian(costs, k);
cost = calculateCost(costs, medoids);
println("Reverse Greedy: ", cost);
toc();

tic()
medoids = Medoids.pam(costs, k);
cost = calculateCost(costs, medoids);
println("PAM: ", cost);
toc();