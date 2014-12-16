# K-medoids algorithm based on Charikar's 1998 LP rounding scheme

function charikar1998{T<:Real}(costs::DenseMatrix{T}, k::Integer)
    # check arguments
    n = size(costs, 1)
    size(costs, 2) == n || error("costs must be a square matrix.")
    k <= n || error("Number of medoids should be less than n.")
end
