using Medoids

# Test parkJun alg on random instance and ORlib instance
algs = [Medoids.parkJun, Medoids.forwardGreedy, Medoids.reverseGreedy, Medoids.pam, Medoids.pamMultiswap]
names = ["parkJun", "forwardGreedy", "reverseGreedy", "PAM", "PAMmultiswap"]
d = 10
n = 100
k = 50
_, costs = Medoids.randomInstance(d, n)
Medoids.testInstance(algs, costs, k)

#=
instances = 5
performance = zeros(1 + length(algs), instances)
for i = 1:instances
    costs, k, opt = Medoids.loadOrLib("./data/orlib", i)
    performance[:, i] = vcat([opt], Medoids.testInstance(algs, costs, k, opt))
end



println(join(vcat(["Optimal"], names), ' '))
for i = 1:size(performance, 2)
    println(join(performance[:, i], ' '))
end

=#
