
# include("plot_test.jl")

using NOMAD

function s(x)
    return abs(floor(x + 1 / 2) - x)
end

function f(w, x)
    Taka = 0;
    for n in 1:100
        Taka += w^n * s(2^n * x[1])
    end
    return Taka
end

function eval_fun(x)

    w = 0.9
    bb_outputs = [-f(w, x)]
    success = true
    count_eval = true
    return (success, count_eval, bb_outputs)
end

pb = NomadProblem(1, # number of inputs of the blackbox
                  1, # number of outputs of the blackbox
                  ["OBJ"], # type of outputs of the blackbox
                  eval_fun;
                #   granularity=0.01 * ones(Float64, 1),
                  lower_bound=[0.],
                  upper_bound=[0.25],
                #   min_mesh_size=[1e-9]
                  )
pb.options.display_degree=3
# pb.options.opportunistic_eval = false
#         pb.options.quad_model_search = false
#         pb.options.nm_search = false
#         pb.options.sgtelib_search = false
#         pb.options.speculative_search = false


result = NOMAD.solve(pb, [0.14])
