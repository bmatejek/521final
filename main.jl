include("./Medoids/src/Medoids.jl")

# Test parkJun alg on random instance and ORlib instance
algs = [Medoids.parkJun, Medoids.forwardGreedy]
d = 2
n = 1000
k = 100
_, costs = Medoids.randomInstance(d, n)
Medoids.testInstance(algs, costs, k)

costs, k, opt = Medoids.loadOrLib("./data/orlib", 1)
Medoids.testInstance(algs, costs, k, opt)
