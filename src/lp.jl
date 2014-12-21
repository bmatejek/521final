# Implements the standard k-median LP relaxation
using JuMP

function buildLP(costs, k, solver=GurobiSolver())
    n = size(costs, 1)
    size(costs, 2) == n || error("Costs must be a square matrix")
    k <= n || error("k must be less than n")

    m = Model()

    @defVar(m, 0 <= x[1:n, 1:n] <= 1) #, Int) # to make it Integer program
    @defVar(m, 0 <= y[1:n] <= 1)

    @addConstraint(m, sum{y[i], i=1:n} <= k)

    for i in 1:n
        for j in 1:n
            @addConstraint(m, x[i,j] <= y[i])
        end
    end

    for j in 1:n
        @addConstraint(m, sum{x[i, j], i=1:n} == 1)
    end

    @setObjective(m, Min, sum{costs[i, j]*x[i, j], i=1:n, j=1:n})
    solve(m)
    m, getValue(x), getValue(y)
end
