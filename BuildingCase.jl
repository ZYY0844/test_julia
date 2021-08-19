using ControlSystems, DirectSearch, Plots, LinearAlgebra, Statistics
using DataFrames,CSV
Revise.track(DirectSearch)
logocolors = Colors.JULIA_LOGO_COLORS
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
h=10
# Tf     = 18143100            # Length of experiments (seconds)
# Tf     = 900*2
Tf=23400*2
# Tf=500
t      = 0:h:Tf          # Time vector
tspan  = (0.0, Tf)

# System Modelling

P = tf(1, [1, -A])

# P = tf(1, [1, 10])
# P              = tf(1, [2.,1])^2 * tf(1, [0.5,1])  # Process model

p_init = [0.1, 0.1, 0.1] # Initial guess [kp, ki, kd]
Kpid(kp, ki, kd) = pid(kp = kp, ki = ki, kd = kd)

ref=16
dis=2.
function disturbance(x,t)
    # return [rand(collect(-2:0.1:2))+2]
    return [dis .* sin(t/200)+2]
end
function reference(x,t)
    # return [rand(collect(-2:0.1:2))+2]
    return [16+2]
end

function ref_temperature(x,t)
    return [2]
end

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
    !isproper(feedback(P * C)) && return Inf
    L     = feedback(P * C) |> ss
    s     = Simulator(L, (x, t) -> [ref]) # Sim. unit step load disturbance
    ty    = eltype(p) # So that all inputs to solve have same numerical type (ForwardDiff.Dual)
    x0    = zeros(L.nx) .|> ty
    x0[1] = 20.
    tspan = (ty(0.), ty(Tf))
    # sol   = solve(s, x0, tspan,saveat=300,reltol = 1,dmin=50)
    # sol   = solve(s, x0, tspan,maxiters=1e8, saveat=8300,reltol = 1)
    sol   = solve(s, x0, tspan, maxiters=1e8,dtmax=10000,reltol = 1e-3)
    # sol   = solve(s, x0, tspan, maxiters=1e8,dtmin=530,reltol = 0.9,force_dtmin=true)
    y     = L.C * sol(t) # y = C*x
    y
end

function Tdis(p)
    C     = Kpid(p[1], p[2], p[3])
    !isproper(P/(1 + P * C)) && return Inf
    L     = P/(1 + P * C) |> ss
    # s     = Simulator(L, (x, t) -> [dis]) # Sim. unit step load disturbance
    s     = Simulator(L, disturbance) # Sim. unit step load disturbance
    ty    = eltype(p) # So that all inputs to solve have same numerical type (ForwardDiff.Dual)
    # x0    =  0.5 .* ones(L.nx) .|> ty
     x0    =  zeros(L.nx) .|> ty
     # x0[1] = 1.
    tspan = (ty(0.), ty(Tf))
    sol   = solve(s, x0, tspan, saveat=300,reltol = 1,dmin=300)
    y     = L.C * sol(t) # y = C*x
    y
end


function Disturbance(p)
    C     = Kpid(p[1], p[2], p[3])
    !isproper(P/(1 + P * C)) && return Inf
    L     = P/(1 + P * C) |> ss
    # ref_L = P/(1 + P * C) |> ss
    e,v=eigen(L.A)
    all(>=(0), e) && return Inf
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

function costfun_test(p)
    f_DS(p)=mean(abs, ref .- (Tref(p) .+ Tdis(p)))  # ~ Integrated absolute error IAE
    return [f_DS]
end

function bi_test(p)
    # IAE(p)=mean(abs, ref .- (Tref(p) .+ Tdis(p)))  # ~ Integrated absolute error IAE
    IAE(p)=mean(abs, ref .- (Tref(p)))  # ~ Integrated absolute error IAE
    sen(p)=Disturbance(p)
    return [IAE, sen]
end

DSp=DS.DSProblem(3; objective = costfun_DS, initial_point = p_init,iteration_limit=2, full_output = true);
# DSp=DS.DSProblem(3; objective = sensitivity, initial_point = p_init,iteration_limit=10, full_output = true);
# DSp=DS.DSProblem(3; objective = bi_test, initial_point = p_init,iteration_limit=100, full_output = true);
# DSp=DS.DSProblem(3; objective = costfun_test, initial_point = p_init,iteration_limit=3, full_output = true);
# @time result=Optimize!(DSp)
@show DSp.x=[3.6, 0.78, 0.200007]
@show DSp.x
@show DSp.x_cost
# @show result
# @show costfun(DSp.x)
# y = Tref(DSp.x)
# y = Tdis(DSp.x)
# @time y = @time Tref(DSp.x) .+ Tdis(DSp.x)
@time y = @time Tref(DSp.x)
# y = @time Tref(DSp.x)
 # @time y = @time Tref(p_init)

@show y[1:20]
display(plot(t,y'))

# C     = Kpid(0.1,0.1,0.1)
# L     = P/(1 + P * C) |> ss
# bodeplot(L)
# @show sensitivity(DSp.[]x)

# fig=scatter()
# for i in 1:length(result)-1
#     fig=scatter!([result[i].cost[1]],[result[i].cost[2]],color=logocolors.red,legend = false)
# end
# display(fig)


# result=[[0.2410,0.00427],[0.29,0.94],[0.726,0.00424],[0.77272,0.00420],[2.5255,0.0041739]]
# fig=scatter()
# for i in 1:5
#     fig=scatter!([result[i][1]],[result[i][2]],color=logocolors.blue,legend = false)
# end
#
# display(fig)
