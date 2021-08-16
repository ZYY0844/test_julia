using DMultiMadsEB
using Plots
using Statistics
logocolors = Colors.JULIA_LOGO_COLORS

# define function
function DTLZ3_fct(x)
    # params
    M = 3 # number of objectives
    n = 12 # number of variables
    k = n - M + 1

    gx = 100 * (k + sum((x[M:n] .- 0.5) .^ 2 - cos.(20 * pi * (x[M:n] .- 0.5))))

    # functions
    ff = ones(M)
    ff[1] = (1 + gx) * prod(cos.(0.5 * pi * x[1:M-1]))
    for i = 2:M
        ff[i] =
            (1 + gx) *
            prod(cos.(0.5 * pi * x[1:M-i])) *
            sin(0.5 * pi * x[M-i+1])
    end

    return ff

end
function test_easy(x)
    f1 = (x[1] + 2) .^ 2 - 10.0 + (x[2] - 3) .^ 2
    f2 = (x[2] - 2) .^ 2 + 20.0 + (x[1] + 1) .^ 2
    # f3(x)=f(x)+f2(x)
    return [f1, f2]
end
function DT1(x)
    m = 30
    f1(x) = x[1]
    g(x) = 1 + 9 .* sum((x[2:m] ./ (collect(2:m) .- 1)))
    h(x) = 1 - sqrt(f1(x) / g(x)) - (f1(x) / g(x)) * sin(10 * pi * f1(x))
    ff2 = g(x) * h(x)
    ff1 = x[1]
    return [ff1, ff2]
end

# define BB problem
# DTLZ3 = BBProblem(x -> DTLZ3_fct(x),
#                   12, 3, # number of variable inputs, number of outputs
#                   [OBJ; OBJ; OBJ], # type of outputs
#                   lvar=zeros(12), # lower bounds
#                   uvar=ones(12), # upper bounds
#                   name="DTLZ3")
function DTLZ2n2(x)

    # params
    M = 2; # Number of objectives
    n = 2; # Number of variables
    k = n - M + 1;

    # g(x)
    gx = sum((x[M:n] .- 0.5).^2);

    # functions
    ff = ones(M);
    ff[1] = (1 + gx ) * prod(cos.(0.5 * pi * x[1:M-1]));
    for i in 2:M
        ff[i] = (1 + gx) * prod(cos.(0.5 * pi * x[1:M-i])) * sin(0.5 * pi * x[M - i + 1]);
    end

    return ff

end
# DTLZ3 = BBProblem(
#     x -> DTLZ2n2(x),
#     30,
#     2, # number of variable inputs, number of outputs
#     [OBJ; OBJ], # type of outputs
#     lvar = zeros(30), # lower bounds
#     uvar = ones(30), # upper bounds
#     name = "DTLZ3",
# )

DTLZ3 = BBProblem(x -> DTLZ2n2(x),
                                    2, 2, # number of variable inputs, number of outputs
                                    [OBJ; OBJ], # type of outputs
                                    lvar=[0.,0.], # lower bounds
                                    uvar=[1.,1.], # upper bounds
                                    name="DTLZ3")



# create mads instance
madsI = MadsInstance(DTLZ3; neval_bb_max = 5000)

# fix gap selection
madsI.gap_selection = 3

# choose start points
# start_points = [DTLZ3.meta.lvar[:,] +  (j - 1) * (DTLZ3.meta.uvar[:,] - DTLZ3.meta.lvar[:,]) / (DTLZ3.meta.ninputs - 1)  for j in 1:DTLZ3.meta.ninputs]

# solve problem; other options can be added
# stop = solve!(madsI, start_points, opportunistic=false)
stop = solve!(madsI, [ones(2) ./ 2], opportunistic = false)
# stop = solve!(madsI, [[0.,0.]], opportunistic=false)

# collect interesting informations
print(madsI.cache.data)
print(madsI.barrier.bestFeasiblePoints)
result = collect(values(madsI.barrier.bestFeasiblePoints))

# fig = scatter()
# for i = 1:length(result)
#     fig = scatter!(
#         [result[i].f[1]],
#         [result[i].f[2]],
#         color = logocolors.red,
#         legend = false,
#     )
# end
# display(fig)
