target = Pkg.dir("Medoids")
source = pwd()
println("ln -s $(source) $(target)")
run(`ln -s $(source) $(target)`)
