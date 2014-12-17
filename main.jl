include("./Medoids/src/Medoids.jl")

# Test parkJun alg on random instance and orlib instance
alg = Medoids.parkJun
d = 5
n = 100
k = 5
_, costs = Medoids.randomInstance(d, n)
Medoids.testInstance(alg, costs, k)

costs, k, opt = Medoids.loadOrLib("./data/orlib", 1)
Medoids.testInstance(alg, costs, k, opt)
