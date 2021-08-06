using ControlSystems, DirectSearch, Plots, LinearAlgebra, Statistics
using DataFrames,CSV
gr(show = false, size = (500, 400)) # Set defaults for plotting

# Data Preparation
# df = CSV.File("tempData.csv",skipto=2) |> DataFrame
# dict_ref=Dict(zip(df[:,1],df[:,2]))
# dict_ext=Dict(zip(df[:,1],df[:,3]))

# some constants
a = 188.36 # wall surface area
U = 0.65  # scaling coeﬃcient
V = 225 # building volume
c_air = 1.005 # air specific heat capacity
ρ_air = 1.225 # air density
n_ac = 0.4 # air changes per hour
A = -(a * U + V * c_air * ρ_air * n_ac)

# Parameters for Simulation
h=900                # Sample time (only used for plots)
h=0.1
# Tf     = 18143100            # Length of experiments (seconds)
# Tf     = 900*2
Tf=5000
t      = 0:h:Tf          # Time vector
tspan  = (0.0, Tf)

# System Modelling

P = tf(1, [1, -A])

# P = tf(1, [1, 10])
# P              = tf(1, [2.,1])^2 * tf(1, [0.5,1])  # Process model

p_init = [0.1, 0.1, 0.1] # Initial guess [kp, ki, kd]
Kpid(kp, ki, kd) = pid(kp = kp, ki = ki, kd = kd)

ref=16
function P_only(p)
    L     = feedback(P) |> ss

    s     = Simulator(L, (x, t) -> [ref]) # Sim. unit step load disturbance
    ty    = eltype(p) # So that all inputs to solve have same numerical type (ForwardDiff.Dual)
    x0    = 10 .* ones(L.nx) .|> ty
    tspan = (ty(0.), ty(Tf))
    sol   = solve(s, x0, tspan)
    y     = L.C * sol(t) # y = C*x
    y

end

function Tref(p)
    C     = Kpid(p[1], p[2], p[3])
    L     = feedback(P * C) |> ss
    s     = Simulator(L, (x, t) -> [ref]) # Sim. unit step load disturbance
    ty    = eltype(p) # So that all inputs to solve have same numerical type (ForwardDiff.Dual)
    x0    = 10 .* ones(L.nx) .|> ty
    tspan = (ty(0.), ty(Tf))
    sol   = solve(s, [20.,0.], tspan)
    y     = L.C * sol(t) # y = C*x
    y
end

# dis=2.
function Disturbance(p)
    C     = Kpid(p[1], p[2], p[3])
    L     = P/(1 + P * C) |> ss
    mag, phase, w = bode(L)
    return maximum(abs.(mag[:,1,1]))
end

function sensitivity(p)
    sen(p)=Disturbance(p)
    return [sen]
end

function costfun_DS(p)
    y(p) = Tref(p)
    f_DS(p)=mean(abs, ref .- y(p))  # ~ Integrated absolute error IAE
    return [f_DS]
end
function costfun(p)
    y = Tref(p)
    mean(abs, ref .- y) # ~ Integrated absolute error IAE
end

# DSp=DS.DSProblem(3; objective = costfun_DS, initial_point = p_init,iteration_limit=10, full_output = true);
DSp=DS.DSProblem(3; objective = sensitivity, initial_point = p_init,iteration_limit=10, full_output = true);
@time Optimize!(DSp)
@show DSp.x
@show DSp.x_cost
@show costfun(DSp.x)
y = Tref(DSp.x)
@show y[1:20]
# y = P_only(1)
display(plot(t,y'))
# bodeplot(P)
