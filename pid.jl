using ControlSystems,Measurements, GenericLinearAlgebra,ForwardDiff,NLopt
using OrdinaryDiffEq, Plots, Interact, Pkg, LinearAlgebra, Statistics
using DirectSearch
gr(show=false, size=(500, 400)) # Set defaults for plotting

P = tf(1, [2.,1])^2 * tf(1, [0.5,1])  # Process model
h = 0.1             # Sample time (only used for plots)
Ps = ss(P);          # State-space representation of process model

s      = Simulator(Ps)
x0     = [0.,0,0] # Initial state
Tf     = 20              # Length of experiments (seconds)
t      = 0:h:Tf          # Time vector
tspan  = (0.0, Tf)

# p = [0.1 0.1 0.1]
Kpid(kp,ki,kd) = pid(kp=kp, ki=ki, kd=kd)
Kpid(p) = K(p...)

function timedomain(p)
    C     = Kpid(p[1], p[2], p[3])
    L     = feedback(P * C) |> ss
    s     = Simulator(L, (x, t) -> [1]) # Sim. unit step load disturbance
    ty    = eltype(p) # So that all inputs to solve have same numerical type (ForwardDiff.Dual)
    x0    = zeros(L.nx) .|> ty
    tspan = (ty(0.), ty(Tf))
    sol   = solve(s, x0, tspan)
    y     = L.C * sol(t) # y = C*x
end
function costfun(p)
    y = timedomain(p)
    mean(abs, 1 .- y) # ~ Integrated absolute error IAE
end

# f_cfg = ForwardDiff.GradientConfig(costfun, p)

# function f(p::Vector, grad::Vector)
#     if length(grad) > 0
#         grad .= ForwardDiff.gradient(costfun, p, f_cfg)
#     end
#     costfun(p)
# end

# function runopt(p; f_tol = 1e-5, x_tol = 1e-3)
#     opt = Opt(:LD_AUGLAG, 3)
#     lower_bounds!(opt, 1e-6ones(3))
#     xtol_rel!(opt, x_tol)
#     ftol_rel!(opt, f_tol)

#     min_objective!(opt, f)
#     NLopt.optimize(opt, p)[2]
# end

p = DSProblem(3; objective=costfun, initial_point=[0.1, 0.1, 0.1]);


@info "Starting Optimization"
@time Optimize!(p)

@show p.status
@show p.x
@show p.x_cost

y = timedomain(p.x)
plot(t,y')

Ω  = exp10.(LinRange(-1, 2, 150))
p0 = [0.1,0.1,0.1]
function freqdomain(p)
    C     = Kpid(p[1], p[2], p[3])
    S     = 1 / (1 + P * C) # Sensitivity fun
    T     = tf(1.) - S# Comp. Sensitivity fun
    Sw    = vec(bode(S, Ω)[1]) # Freq. domain constraints
    Tw    = vec(bode(T, Ω)[1]) # Freq. domain constraints
    Sw, Tw
end

Ms = 1.2 # Maximum sensitivity 
Mt = 1.5 # Maximum comp. sensitivity