module Medoids
    using Clustering

    type KmedoidsResult{T}
        medoids::Vector{Int}        # indices of methods (k)
        assignments::Vector{Int}    # assignments (n)
        acosts::Vector{T}           # costs of the resultant assignments (n)
        counts::Vector{Int}         # number of samples assigned to each cluster (k)
        totalcost::Float64          # total assignment cost (i.e. objective) (k)
        iterations::Int             # number of elapsed iterations
        converged::Bool             # whether the procedure converged
    end

    export
    # Utilities
    loadOrLib, randomInstance, testInstance,
    calculateCost,

    # Implementation from clustering.jl
    parkJun, parkJun!,

    # PAM
    pam,

    # Greedy
    forwardGreedy, backwardGreedy,

    # Linear Programs
    charikar1998, charikar2012, buildLP


    # Source files
    include("utils.jl")
    include("parkJun.jl")
    include("greedy.jl")
    include("charikar1998.jl")
    include("charikar2012.jl")
    include("pam.jl")
    include("lp.jl")
end
