using ControlSystems, OrdinaryDiffEq, Plots, Interact, Pkg, LinearAlgebra, Statistics,Debugger,Infiltrator
using NLopt, ForwardDiff,DirectSearch
gr(show=false, size=(500, 400)) # Set defaults for plotting

P              = tf(1, [2.,1])^2 * tf(1, [0.5,1])  # Process model
# P = tf(1, [1, 200])
h              = 0.1             # Sample time (only used for plots)
# Ps             = ss(P);          # State-space representation of process model

# s      = Simulator(Ps)
x0     = [0.,0,0] # Initial state
Tf     = 20           # Length of experiments (seconds)
t      = 0:h:Tf          # Time vector
tspan  = (0.0, Tf)


p              = [0.1, 0.1, 0.1] # Initial guess [kp, ki, kd]

Kpid(kp,ki,kd) = pid(kp=kp, ki=ki, kd=kd)
Kpid(p)        = K(p...)
ref=1

function ff(x,t)
    return [ref]
end

function timedomain(p)

    C     = Kpid(p[1], p[2], p[3])
    L     = feedback(P * C) |> ss
    s     = Simulator(L, ff) # Sim. unit step load disturbance
    ty    = eltype(p) # So that all inputs to solve have same numerical type (ForwardDiff.Dual)
    x0    = 1 .* zeros(L.nx) .|> ty
    tspan = (ty(0.), ty(Tf))
    sol   = solve(s, x0, tspan)
    y     = L.C * sol(t) # y = C*x
    y
end

function costfun_DS(p)
    y(p) = timedomain(p)
    f_DS(p)=mean(abs, ref .- y(p))  # ~ Integrated absolute error IAE
    return [f_DS]
end
function costfun(p)
    y = timedomain(p)
    mean(abs, ref .- y) # ~ Integrated absolute error IAE
end

@time DSp=DS.DSProblem(3; objective = costfun_DS, initial_point = [0.1, 0.1, 0.1],iteration_limit=10000, full_output = false);
Optimize!(DSp)
@show DSp.x
@show DSp.x_cost
@show costfun(DSp.x)
y = timedomain(DSp.x)
display(plot(t,y'))

#
# C     = Kpid(DSp.x...)
# gangoffourplot(P,C, exp10.(LinRange(-1,3,500)), legend=false)


#
# C     = Kpid(p...)
# gangoffourplot(P,C, exp10.(LinRange(-1, 3, 500)), legend=false)
#
# Ω  = exp10.(LinRange(-1, 2, 150))
# p0 = [0.1,0.1,0.1]
# function freqdomain(p)
#     C     = Kpid(p[1], p[2], p[3])
#     S     = 1 / (1 + P * C) # Sensitivity fun
#     T     = tf(1.) - S# Comp. Sensitivity fun
#     Sw    = vec(bode(S, Ω)[1]) # Freq. domain constraints
#     Tw    = vec(bode(T, Ω)[1]) # Freq. domain constraints
#     Sw, Tw
# end
# Mt = 1.5
# @manipulate for Ms = LinRange(1.1, 2, 20)
#     global p0, p
#     p = p0
#     function constraintfun(p)
#         Sw, Tw = freqdomain(p)
#         [maximum(Sw) - Ms; maximum(Tw) - Mt]
#     end
#
#     g_cfg = ForwardDiff.JacobianConfig(constraintfun, p)
#
#     function c(result, p::Vector, grad)
#         if length(grad) > 0
#             grad .= ForwardDiff.jacobian(constraintfun, p, g_cfg)'
#         end
#         result .= constraintfun(p)
#     end
#
#     function runopt(p; f_tol=1e-5, x_tol=1e-3, c_tol=1e-8)
#         opt = Opt(:LD_SLSQP, 3)
#         lower_bounds!(opt, 1e-6ones(3))
#         xtol_rel!(opt, x_tol)
#         ftol_rel!(opt, f_tol)
#
#         min_objective!(opt, f)
#         inequality_constraint!(opt, c, c_tol * ones(2))
#         NLopt.optimize(opt, p)[2]
#     end
#
#
#     p = runopt(p, x_tol=1e-6)
#     y = timedomain(p)
#     Sw, Tw = freqdomain(p)
#     plot(t, y', layout=2, size=(800, 400))
#     plot!(Ω, [Sw Tw], lab=["Sw" "Tw"], subplot=2, xscale=:log10, yscale=:log10)
#     plot!([Ω[1],Ω[end]], [Ms,Ms], c=:black, l=:dash, subplot=2, lab="Ms")
#     plot!([Ω[1],Ω[end]], [Mt,Mt], c=:purple, l=:dash, subplot=2, lab="Mt", ylims=(0.01, 3))
# end
#
# C     = Kpid(p...)
# gangoffourplot(P,C, exp10.(LinRange(-1, 3, 500)), legend=false)
