using Distances
using Graphs

include("Medoids.jl");

using Medoids

type DataPoint
    coordinates
end

function euclideandistance(xi::DataPoint, xj::DataPoint)
    return sqrt(sum((xi.coordinates - xj.coordinates) .^2));
end

function readFileORLib(filename::String)
    f = open(filename);
    nv, ne, k = [int(v) for v in split(strip(readline(f)))];
    
    costs = fill(typemax(Int32), nv, nv);
    for ln in eachline(f)
        ne -= 1;
        i, j, distance = [int(v) for v in split(strip(fln))];
        costs[i, j] = costs[j, i] = distance;
    end
    ne == 0 || error("$(ne) fewer lines than there should be");
    floyd_warshall!(costs)
    cCosts = deepcopy(costs);
    costs, cCosts, k
end


function readFileUniform(filename::String)
    tic();
    fd = open(filename);
    data = readlines(fd)
    openingFacilities = false
    openingClients = false
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
        elseif (contains(line, "# clients"))
            k += 1
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
    if (length(clients) > 1000 || length(facilities) > 1000)
        close(fd);
        exit(-1);
    end
    close(fd);

    costs = fill(typemax(Float64), length(facilities), length(clients));
    cCosts = fill(typemax(Float64), length(clients), length(clients));
    for i=1:length(facilities)
        for j=1:length(clients)
            costs[i, j] = euclideandistance(facilities[i], clients[j]);
        end
    end
    
    for i=1:length(clients)
        for j=1:length(clients)
            cCosts[i, j] = euclideandistance(clients[i], clients[j]);
        end
    end
    costs, cCosts, k        
end


function readFileGauss(filename::String)
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
    
    for i=1:length(clients)
        for j=1:length(clients)
            cCosts[i, j] = euclideandistance(clients[i], clients[j]);
        end
    end
    costs, cCosts, k
end

filename = ARGS[1];

if (contains(filename, "uniform"))
    costs, cCosts, k = readFileUniform(filename);
elseif (contains(filename, "orlib"))
    costs, cCosts, k = readFileORLib(filename);
else
    costs, cCosts, k = readFileGauss(filename);
end

println(filename);
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

tic();
medoids = Medoids.charikar2012(costs, k, cCosts);
cost = calculateCost(costs, medoids);
println("Charikar Multiple Iterations: ", cost);
toc();

tic();
medoids = Medoids.forwardGreedyBrian(costs, k);
cost = calculateCost(costs, medoids);
println("Forward Greedy: ", cost);
toc();


tic();
medoids = Medoids.jv(costs, k);
cost = calculateCost(costs, medoids);
println("JV: ", cost);
toc();

if (size(costs, 1) < 50 && size(costs, 2) < 50)
    tic();
    medoids = Medoids.reverseGreedyBrian(costs, k);
    cost = calculateCost(costs, medoids);
    println("Reverse Greedy: ", cost);
    toc();
    
    tic();
    medoids = Medoids.pam(costs, k);
    cost = calculateCost(costs, medoids);
    println("PAM: ", cost);
    toc();
    
    tic();
    medoids = Medoids.pamMultiswap(costs, k);
    cost = calculateCost(costs, medoids);
    println("PAM Multiswap: ", cost);
    toc();
end