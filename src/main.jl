using Medoids

# Test parkJun alg on random instance and ORlib instance
#algs = [Medoids.parkJun, Medoids.forwardGreedy, Medoids.reverseGreedy, Medoids.pam]
#names = ["parkJun", "forwardGreedy", "reverseGreedy", "PAM"]

#d = 10
#n = 100
#k = 50
#_, costs = Medoids.randomInstance(d, n)
#Medoids.testInstance(algs, costs, k)

algs = [Medoids.charikar2012];
names = ["charikar2012"];


instances = 3
algs = [Medoids.parkJun, Medoids.forwardGreedy, Medoids.reverseGreedy, Medoids.pam, Medoids.pamMultiswap]
names = ["parkJun", "forwardGreedy", "reverseGreedy", "PAM", "PAMmultiswap"]
d = 10
n = 100
k = 50
_, costs = Medoids.randomInstance(d, n)
Medoids.testInstance(algs, costs, k)

