# K-medoids implementatoin based on the commonly used PAM algorithm

function pam{T<:Real}(costs::DenseMatrix{T}, k::Integer)
    # check arguments
    n = size(costs, 1)
    size(costs, 2) == n || error("costs must be a square matrix.")
    k <= n || error("Number of medoids should be less than n.")
end
