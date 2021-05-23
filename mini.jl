
include("plot_test.jl")
using NOMAD

function s(x)
    return abs(floor(x + 1 / 2) - x)
end

function f(w, x)
    Taka = 0;
    for n in 1:100
        Taka += w^n * s(2^n * x)
    end
    return Taka
end

function c(x)
    return -1
end

function eval_fct(x)
    bb_outputs = [-f(0.9, x), c(x)]
    success = true
    count_eval = true
    return (success, count_eval, bb_outputs)
end
pb = NomadProblem(1, # number of inputs of the blackbox
  2, # number of outputs of the blackbox
  ["OBJ", "EB"], # type of outputs of the blackbox
  eval_fct,
  lower_bound=[-0.],
  upper_bound=[0.25])
result = NOMAD.solve(pb, [0.1])



# function eval_fun(x::Float64)
#     w = 0.9
#     bb_outputs = [-f(w, x)]
#     success = true
#     count_eval = true
#     return (success, count_eval, bb_outputs)
# end

# pb = NomadProblem(1, # number of inputs of the blackbox
#                   1, # number of outputs of the blackbox
#                   ["OBJ"], # type of outputs of the blackbox
#                   eval_fun;
#                   lower_bound=[0.],
#                   upper_bound=[0.25])

# result = NOMAD.solve(pb, [0.1])
