using DirectSearch
using Plots
using Statistics
using LinearAlgebra
logocolors = Colors.JULIA_LOGO_COLORS
gr(show = false, size = (400, 400))
Revise.track(DirectSearch)


    function DPAM1(x)

        # params
        n = 10
        A = [0.218418 -0.620254 0.843784 0.914311 -0.788548 0.428212 0.103064 -0.47373 -0.300792 -0.185507;
             0.330423 0.151614 0.884043 -0.272951 -0.993822 0.511197  -0.0997948 -0.659756 0.575496 0.675617;
             0.180332    -0.593814    -0.492722    0.0646786   -0.666503   -0.945716  -0.334582     0.611894     0.281032      0.508749;
             -0.0265389   -0.920133     0.308861   -0.0437502   -0.374203    0.207359    -0.219433     0.914104     0.184408      0.520599;
             -0.88565     -0.375906    -0.708948   -0.37902      0.576578    0.0194674  -0.470262     0.572576     0.351245     -0.480477;
             0.238261    -0.1596      -0.827302    0.669248     0.494475    0.691715    -0.198585     0.0492812    0.959669      0.884086;
             -0.218632    -0.865161    -0.715997    0.220772     0.692356    0.646453    -0.401724     0.615443    -0.0601957    -0.748176;
             -0.207987    -0.865931     0.613732   -0.525712    -0.995728    0.389633 -0.064173     0.662131    -0.707048     -0.340423;
             0.60624      0.0951648   -0.160446   -0.394585    -0.167581    0.0679849 0.449799     0.733505    -0.00918638    0.00446808;
             0.404396     0.449996     0.162711    0.294454    -0.563345   -0.114993    0.549589    -0.775141     0.677726      0.610715];

        y = A * x

        # gx
        gx = 1 + 10 * (n - 1) + sum(y[2:n].^2 - 10 * cos.(4 * pi * y[2:n]))

        # objective functions
        f1 = y[1]
        f2 = gx * exp(-y[1]/gx)
        return [f1;f2]

    end

m=10
function F1(x)
    f1(x)=DPAM1(x)[1]
    f2(x)=DPAM1(x)[2]
    return [f1,f2]
end

p = DSProblem(m; objective=F1,initial_point=zeros(m) ./2, iteration_limit=100000,full_output=false);
# AddStoppingCondition(p, HypervolumeStoppingCondition(4.13))
# AddStoppingCondition(p, RuntimeStoppingCondition(4.1320))
SetFunctionEvaluationLimit(p,10000000)

# SetVariableRange(p,1,0.,0.19
# cons1(x) = 0. < x[1] < 1.
# AddExtremeConstraint(p, cons1)
for i=1:m
    cons(x) = (-0.3 <= x[i] <=0.3)
    AddExtremeConstraint(p, cons)
end

# cons2(x) = -5. < x[2:30] <5.
# AddExtremeConstraint(p, cons2)

# AddStoppingCondition(p, ButtonStoppingCondition("quit"))
# SetIterationLimit(p,2)
# AddStoppingCondition(p, RuntimeStoppingCondition(0.01))
# SetRuntimeLimit(p, 0.2)

result=Optimize!(p)
# @show p.status
# @show p.x
# @show p.x_cost
# @show p.status.iteration
# @show paretoCoverage(result)
# @show hvIndicator(result)
fig=scatter()
for i in 1:length(result)
    fig=scatter!([result[i].cost[1]],[result[i].cost[2]],color=logocolors.red,legend = false)
end

plot!(fig,xlabel="f1 cost",ylabel="f2 cost")
display(fig)
# savefig(fig, "./test_functions/pareto_result/DPAM1.pdf")
