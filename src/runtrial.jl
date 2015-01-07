using Medoids

function runTrial(outDir, algName, instanceType, instanceNum)
    println("$(algName) | $(instanceType) | $(instanceNum)")
    if !isdir(outDir)
        println("Directory does not exist: $(outDir)")
        return
    end

    if instanceType == "orlib"
        costs, k, opt = Medoids.loadOrLib("./data/orlib", int(instanceNum))
    else
        println("Unknown instance type $(instanceType)")
        return
    end

    if algName == "parkJun"
        alg = Medoids.parkJun
    elseif algName == "forwardGreedy"
        alg = Medoids.forwardGreedy
    elseif algName == "reverseGreedy"
        alg = Medoids.reverseGreedy
    elseif algName == "charikar2012"
        alg = Medoids.charikar2012
    elseif algName == "PAM"
        alg = Medoids.pam
    else
        println("Unknown algorithm $(algName)")
        return
    end

    tic()
    medoids = alg(costs, k)
    time = toq()
    performance = Medoids.calculateCost(costs, medoids)

    f = open(joinpath(outDir, "$(alg)_$(instanceType)_$(instanceNum).yml"), "w")
    write(f, "alg: $(algName)\n")
    write(f, "instanceType $(instanceType)\n")
    write(f, "instanceNumber $(instanceNum)\n")
    write(f, "k: $(k)\n")
    write(f, "medoids: $(medoids)\n")
    write(f, "performance: $(performance)\n")
    write(f, "time: $(time)\n")

    close(f)
end
