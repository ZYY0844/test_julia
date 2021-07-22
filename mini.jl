
# include("plot_test.jl")

using NOMAD

# function f1(x)
#   return x[1] * x[1] - x[2] * x[2]
# end
#
# function f2(x)
#   return x[1]/x[2]
# end

function f1(x)
  return (x[1]+2).^2 - 10
end

function f2(x)
  return (x[1]-2).^2 + 20
end

function eval_fct(x)
  bb_outputs = [f1(x), f2(x)]
  success = true
  count_eval = true
  return (success, count_eval, bb_outputs)
end

pb = NomadProblem(1, # number of inputs of the blackbox
                  2, # number of outputs of the blackbox
                  ["OBJ", "OBJ"], # type of outputs of the blackbox
                  eval_fct;
                  lower_bound=[-1.5],
                  upper_bound=[0.])

result = solve(pb, [-0.3])



# function s(x)
#     return abs(floor(x + 1 / 2) - x)
# end
#
# function f(w, x)
#     Taka = 0;
#     for n in 1:100
#         Taka += w^n * s(2^n * x[1])
#     end
#     return Taka
# end
#
# function eval_fun(x)
#
#     w = 0.9
#     bb_outputs = [-f(w, x)]
#     success = true
#     count_eval = true
#     return (success, count_eval, bb_outputs)
# end
#
# pb = NomadProblem(1, # number of inputs of the blackbox
#                   1, # number of outputs of the blackbox
#                   ["OBJ"], # type of outputs of the blackbox
#                   eval_fun;
#                 #   granularity=0.01 * ones(Float64, 1),
#                   lower_bound=[0.],
#                   upper_bound=[0.25],
#                 #   min_mesh_size=[1e-9]
#                   )
# pb.options.display_degree=3
# # pb.options.opportunistic_eval = false
# #         pb.options.quad_model_search = false
# #         pb.options.nm_search = false
# #         pb.options.sgtelib_search = false
# #         pb.options.speculative_search = false
#
#
# result = NOMAD.solve(pb, [0.14])
