# Usage: julia -p <Num Processors> -L src/runtrial.jl src/runtrials.jl output_directory experiment_file

function runTrials(outDir, filename)
    experiment = open(filename)
    @sync for ln in eachline(experiment)
        @spawn runTrial(outDir, split(ln)...)
    end
end

if length(ARGS) < 2
    println("usage: julia $(basename(@__FILE__())) out_directory experiment_file")
    exit()
end

println(ARGS)
runTrials(ARGS[1], ARGS[2])
