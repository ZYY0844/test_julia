# function f(x)
#     return x[1]^2 + x[2]^2
# end

# function c(x)
#     return 1 - x[1]
# end

# function eval_fct(x)
#     bb_outputs = [f(x), c(x)]
#     success = true
#     count_eval = true
#     return (success, count_eval, bb_outputs)
# end

# pb = NomadProblem(2, # number of inputs of the blackbox
#                   2, # number of outputs of the blackbox
#                   ["OBJ", "EB"], # type of outputs of the blackbox
#                   eval_fct;
#                   lower_bound=[-5.0, -5.0],
#                   upper_bound=[5.0, 5.0])

# result = solve(pb, [3.0, 3.0])
include"a.jl"
function mandelbrot(a)
    z = 0
    for i = 1:50
        z = z^2 + a
    end
    return z
end
a(6);
for y = 1.0:-0.05:-1.0
    for x = -2.0:0.0315:0.5
        abs(mandelbrot(complex(x, y))) < 2 ? print("*") : print(" ")
    end
    println()
end