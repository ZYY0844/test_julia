using ControlSystems, DirectSearch, Plots, LinearAlgebra, Statistics, ODE
using DataFrames,CSV,LaTeXStrings
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
h=1000            # Sample time (only used for plots)
# h=2000
period=5000*4
# Tf     = 18143100            # Length of experiments (seconds)
# Tf     = 900*2
# Tf=23400
# Tf=6000
Tf=period*4
t      = 0:h:Tf          # Time vector
tspan  = (0.0, Tf)

# System Modelling

P = tf(1, [1, -A])
p_init = [0.1,0.1,0.1] # Initial guess [kp, ki, kd]
Kpid(kp, ki, kd) = pid(kp = kp, ki = ki, kd = kd)

ref=18
dis=0.5
function disturbance(x,t)
    # return [rand(collect(-2:0.1:2))+2]
    return [dis .* sin(t/500)+2]
end
function reference(x,t)
    res=18-(-1)^trunc(t/period)*2
    return [res]
end


function Tref(p) #take the P,I,D values as an input
    # P = tf(1, [1, -A])  #transfer functions (tf) for the system
    C     = Kpid(p[1], p[2], p[3]) #tf for PID controller
    L     = feedback(P * C) |> ss #tf for feedback loop pc/(1+pc) and convert it to state-space representation

    #if the obtained system is improper
    # !isproper(feedback(P * C)) && return Inf
    #if the obtained system is stable
    e,v=eigen(L.A)
    # any(>=(0), e) && println("unstable") && return Inf

    #Translate the system with tf=L and input signal=ref to a manner that can be solved by an ODE solver
    s     = Simulator(L, reference)
    ty    = eltype(p) # So that all inputs to the solver have same numerical type
    x0    = zeros(L.nx) .|> ty
    x0[1] = 34
    tspan = (ty(0.), ty(Tf)) #total simulation period
    sol   = solve(s, x0, tspan,maxiters=1e7,dtmax=100,dtmin=0.001,reltol = 1e-2,force_dtmin=true)
    # sol   = solve(s, x0, tspan,maxiters=1e8, saveat=collect(0.:30*2:Tf),reltol = 1e-1)
    # sol   = solve(s, x0, tspan, maxiters=1e8,dtmax=10000,reltol = 1e-1)
    # sol   = solve(s, x0, tspan, maxiters=1e8,dtmin=530,reltol = 0.9,force_dtmin=true)
    # y     = L.C * sol(t)+ L.D*18 .* ones(201)' # y = C*x
    y     = L.C * sol(t)
    y
end

# function Tref(p)
#     C     = Kpid(p[1], p[2], 0)|> ss
#     P     = tf(1, [1, -A]) |>ss
#     CP=series(P,C)
#     !isproper(feedback(P * C)) && return Inf
#     L     = feedback(CP)
#
#     e,v=eigen(L.A)
#     any(>=(0), e) && println("unstable") && return Inf
#
#     s     = Simulator(L, reference) # Sim. unit step load disturbance
#     ty    = eltype(p) # So that all inputs to solve have same numerical type (ForwardDiff.Dual)
#     x0    = zeros(L.nx) .|> ty
#     x0[1] = 16
#     tspan = (ty(0.), ty(Tf))
#     sol   = solve(s, x0, tspan,maxiters=1e7,dtmax=100,dtmin=0.01,reltol = 1e-1,force_dtmin=true)
#     # sol   = solve(s, x0, tspan,maxiters=1e8, saveat=collect(0.:30*2:Tf),reltol = 1e-1)
#     # sol   = solve(s, x0, tspan, maxiters=1e8,dtmax=10000,reltol = 1e-1)
#     # sol   = solve(s, x0, tspan, maxiters=1e8,dtmin=530,reltol = 0.9,force_dtmin=true)
#     y     = L.C * sol(t) # y = C*x
#     # y=L.C*sol(t)
#     # display(plot(sol(t)))
#     y
# end

# function Tdis(p)
#     C     = Kpid(p[1], p[2], p[3])
#     !isproper(P/(1 + P * C)) && return Inf
#     L     = P/(1 + P * C) |> ss
#     # s     = Simulator(L, (x, t) -> [dis]) # Sim. unit step load disturbance
#     s     = Simulator(L, disturbance) # Sim. unit step load disturbance
#     ty    = eltype(p) # So that all inputs to solve have same numerical type (ForwardDiff.Dual)
#     # x0    =  0.5 .* ones(L.nx) .|> ty
#      x0    =  zeros(L.nx) .|> ty
#      # x0[1] = 1.
#     tspan = (ty(0.), ty(Tf))
#     sol   = solve(s, x0, tspan, maxiters=1e7,dtmax=100,dtmin=0.01,reltol = 1e-1,force_dtmin=true)
#     y     = L.C * sol(t) # y = C*x
#     y
# end

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
    sol   = solve(s, x0, tspan, maxiters=1e7,dtmax=100,dtmin=0.01,reltol = 1e-1,force_dtmin=true)
    y     = L.C * sol(t) # y = C*x
    y
end
function Disturbance(p)
    C     = Kpid(p[1], p[2], p[3])
    !isproper(P/(1 + P * C)) && return Inf
    L     = P/(1 + P * C) |> ss
    e,v=eigen(L.A) #ensure the system is stable
    any(>=(0), e) && return Inf

    mag, phase, w = bode(L)
    return maximum(abs.(mag[:,1,1]))
end

function sensitivity(p)
    sen(p)=Disturbance(p)
    return [sen]
end

function costfun_DS(p)
    # len=ceil((period*3)/h)
    # r1=2*ones()
    f_DS(p)=mean(abs, ref .- Tref(p))  # ~ Integrated absolute error IAE
    return [f_DS]
end
# function costfun_DS(p)
#     y=Tref(p)
#     f_DS(p)=mean(abs, (18+(-1)^trunc(t/period)*2) .- Tref(p))  # ~ Integrated absolute error IAE
#     return [f_DS]
# end

function costfun(p)
    y = Tref(p)
    mean(abs, ref .- y) # ~ Integrated absolute error IAE
end

function costfun_test(p)
    f_DS(p)=mean(abs, ref .- (Tref(p) .+ Tdis(p)))  # ~ Integrated absolute error IAE
    return [f_DS]
end

function bi_test(p)
    IAE(p)=mean(abs, ref .- (Tref(p) .+ Tdis(p)))  # ~ Integrated absolute error IAE
    # IAE(p)=mean(abs, ref .- (Tref(p)))  # ~ Integrated absolute error IAE
    sen(p)=Disturbance(p)
    return [IAE, sen]
end

DSp=DS.DSProblem(3; objective = costfun_DS, initial_point = p_init,iteration_limit=10, full_output = true);
# DSp=DS.DSProblem(3; objective = sensitivity, initial_point = p_init,iteration_limit=100, full_output = true);
# DSp=DS.DSProblem(3; objective = bi_test, initial_point = p_init,iteration_limit=20, full_output = true);
# DSp=DS.DSProblem(3; objective = costfun_test, initial_point = p_init,iteration_limit=10, full_output = true);
# @time result=Optimize!(DSp)
# DSp.x = [-0.75, 0.62, 0.08000000000000002]
# @show DSp.x= [-0.55, 0.62, 0.08000000000000002]
# @show DSp.x=[-0.45, 0.67, 0.10000000000000002]
# @show DSp.x=[-0.25, 0.47000000000000003, 0.17]
# @show DSp.x=[6, 0,0]
DSp.x = [0.5,0.5,0.5]
# @show DSp.x=[-0.25, 0.47000000000000003, 1.3877787807814457e-17]
@show DSp.x
@show DSp.x_cost
# @show result
@show costfun(DSp.x)
@show Disturbance(DSp.x)
# y = Tref(DSp.x)
# y = Tdis(DSp.x)
# @time y = Tref(DSp.x)+Tdis(DSp.x)
# @time y = @time Tref(DSp.x)
@show length(y)
# y = @time Tref(DSp.x)
 # @time y = @time Tref(p_init)

# y[101]=y[100]
y= y .+1.4
@show y[1:20]
@show y[30:60]
# @show y[90:110]
# @show typeof(y)
function set_T(t)
    res=18-(-1)^trunc(t/period)*2
end
temp=set_T.(t)


# dis=18-(-1)^trunc(t/period)*2+dis .* sin(t/1000)+2
# fig=plot(t,y')
# fig=plot(t[1:200],(y')[1:200],xlims=(0,Tf+1500),xticks = 0:5e3:Tf)
# fig=plot(t[750:1200],(y')[750:1200])
fig=plot(t[1:500],(y')[1:500])

# plot!(t[1:200],temp[1:200])
# plot!(fig,fg_legend=:transparent,legend=:bottomright,linewidth = 2)
# plot!(fig,xlabel="Time (sec)",ylabel="Temperature (ᵒC)",label=["T (PID)" "T (Set)"])
# plot!(fig,xlabel="Integrated absolute error",ylabel="Maximum sensitivity")

display(fig)
# savefig(fig, "./temp_fig/worse.pdf")

# C     = Kpid(0.1,0.1,0.1)
# L     = P/(1 + P * C) |> ss
# bodeplot(L)
# @show sensitivity(DSp.[]x)

# fig=scatter()
# for i in 1:length(result)-1
#     fig=scatter!([result[i].cost[1]],[result[i].cost[2]],color=logocolors.red,legend = false)
# end
# display(fig)

#
# result = [
#     [1.740694569909919, 0.004296767402026843],
#     [1.7417687236440276, 0.0042930820525685],
#     [1.7543735728347578, 0.004291074787029342],
#     [1.8890603895556883, 0.004287382076502],
#     [1.8008510990578937,0.004289965110630173],
#     [2.5879840594943966,0.004285656181],
#     # [17.86, 0.004141040680085014]
# ]
# fig=scatter()
# for i in 1:6
#     fig=scatter!([result[i][1]],[result[i][2]],color=logocolors.blue,legend = false)
# end
# plot!(fig,xlabel="Integrated absolute error",ylabel="Maximum sensitivity",yticks = 0.00428:0.00001:0.00430)
# display(fig)
#  savefig(fig, "./temp_fig/pareto2.pdf")
#
# y=dis .* sin.(t/500) .+2
# fig2=plot(t,y,xlims=(0,Tf+1500),xticks = 0:5e3:Tf,xlabel="Time (sec)",ylabel="Temperature (ᵒC)",label="T (Distrubance)")
#
# display(fig2)
# savefig(fig2, "./temp_fig/disturbance.pdf")
