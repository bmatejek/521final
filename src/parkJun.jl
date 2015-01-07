# K-medoids algorithm based on Park & Jun's algorithm
# From Clustering.jl library
using Clustering

function parkJun{T<:Real}(costs::DenseMatrix{T}, k::Integer)
    result = Clustering.kmedoids(costs, k)
    collect(result.medoids)
end
