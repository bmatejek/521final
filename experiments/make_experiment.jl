f = open(ARGS[1], "w")

for alg = ["parkJun", "forwardGreedy", "reverseGreedy", "PAM"]
    for i = 1:40
        write(f, "$(alg) orlib $(i)\n")
    end
end
close(f)
