module Medoids
    using Clustering

    abstract ClusteringResult

    type KmedoidsResult{T} <: ClusteringResult
        medoids::Vector{Int}        # indices of methods (k)
        assignments::Vector{Int}    # assignments (n)
        acosts::Vector{T}           # costs of the resultant assignments (n)
        counts::Vector{Int}         # number of samples assigned to each cluster (k)
        totalcost::Float64          # total assignment cost (i.e. objective) (k)
        iterations::Int             # number of elapsed iterations
        converged::Bool             # whether the procedure converged
    end

    export
    # Implementation with clustering.jl
    parkJun, parkJun!,

    charikar1998, charikar2012,
    # PAM
    pam


    # Include algorithms
    include("parkJun.jl")
    include("charikar1998.jl")
    include("charikar2012.jl")
    include("pam.jl")


    # Bunch of stuff for the Clustering.jl library to work
    display_level(s::Symbol) =
        s == :none ? 0 :
        s == :final ? 1 :
        s == :iter ? 2 :
        error("Invalid value for the option 'display'.")
end
