using ControlSystems, Plots
tfinal=5000
t = 0:1:tfinal
P = tf(1, [1, 233])
K_p = 10

# L = feedback(K_p * P) |> ss
L = (K_p * P)/(1+(K_p * P)) |> ss
s = Simulator(L, (x, t) -> [16])
x0 = [0,0]
tspan = (0.0, tfinal)
sol = solve(s, x0, tspan)
y     = L.C * sol(t)
# plot(t,y')
# plot(sol(t))
plot(t, s.y(sol, t)[:], lab = "close loop step response")

# using ControlSystems, Plots
#
# logocolors = Colors.JULIA_LOGO_COLORS
# gr(show = false, size = (500, 400)) # Set defaults for plotting
#
# # Parameters for Simulation
# h=100               # Sample time (only used for plots)
# Tf=5000
# t      = 0:h:Tf          # Time vector
# tspan  = (0.0, Tf)
#
# # System Modelling
# P = tf(1, [1, 233])
# Kpid(kp, ki, kd) = pid(kp = kp, ki = ki, kd = kd)
#
#
# # for transfer function version
# function Tref(p)
#     C     = Kpid(p[1], p[2], p[3])
#     L     = feedback(P * C) |> ss
#
#     s     = Simulator(L, (x,t) -> [30]) # Sim. unit step load disturbance
#     ty    = eltype(p) # So that all inputs to solve have same numerical type (ForwardDiff.Dual)
#     x0    = zeros(L.nx) .|> ty
#     # x0[1] = 16
#     tspan = (ty(0.), ty(Tf))
#     sol   = solve(s, x0, tspan)
#     # y     = L.C * sol(t)+ L.D*18 .* ones(201)' # y = C*x
#     y     = L.C * sol(t)
#     @show L.C
#     # display(plot(sol(t)))
#     y
# end
#
# # for state-space version
# # function Tref(p)
# #     P = tf(1, [1, 233])
# #     C     = Kpid(p[1], p[2], 0)|> ss
# #     P     = P |>ss
# #     CP=series(P,C)
# #     L     = feedback(CP)
# #
# #
# #     s     = Simulator(L, reference) # Sim. unit step load disturbance
# #     ty    = eltype(p) # So that all inputs to solve have same numerical type (ForwardDiff.Dual)
# #     x0    = zeros(L.nx) .|> ty
# #     x0[1] = 16
# #     tspan = (ty(0.), ty(Tf))
# #     sol   = solve(s, x0, tspan,maxiters=1e7,dtmax=100,dtmin=0.01,reltol = 1e-1,force_dtmin=true)
# #     # sol   = solve(s, x0, tspan,maxiters=1e8, saveat=collect(0.:30*2:Tf),reltol = 1e-1)
# #     # sol   = solve(s, x0, tspan, maxiters=1e8,dtmax=10000,reltol = 1e-1)
# #     # sol   = solve(s, x0, tspan, maxiters=1e8,dtmin=530,reltol = 0.9,force_dtmin=true)
# #     y     = L.C * sol(t) # y = C*x
# #     # y=L.C*sol(t)
# #     # display(plot(sol(t)))
# #     y
# # end
#
# # p=[-0.45, 0.67, 0.10000000000000002]
# p=[6,0,0]
# y =Tref(p)
# # @show y[1:20]
# # fig=plot(t[1:200],(y')[1:200],xlims=(0,Tf+1500),xticks = 0:5e3:Tf)
# plot(t,y')
# display(fig)
