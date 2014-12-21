target = Pkg.dir("Medoids")
source = pwd()
print("ln -s $(source) $(target)")
run(`ln -s $(source) $(target)`)
