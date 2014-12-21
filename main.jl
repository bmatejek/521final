include("./Medoids/src/Medoids.jl")

# Test parkJun alg on random instance and ORlib instance
algs = [Medoids.parkJun, Medoids.forwardGreedy, Medoids.reverseGreedy, Medoids._reverseGreedyOpt]
d = 10
n = 100
k = 50
_, costs = Medoids.randomInstance(d, n)
Medoids.testInstance(algs, costs, k)

instances = 5
performance = zeros(instances, length(algs))
for i = 1:instances
    costs, k, opt = Medoids.loadOrLib("./data/orlib", i)
    performance[i, :] = Medoids.testInstance(algs, costs, k, opt)
end
print(performance)
