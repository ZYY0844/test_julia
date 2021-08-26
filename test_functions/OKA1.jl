using DirectSearch
using Plots
using Statistics
using LinearAlgebra
logocolors = Colors.JULIA_LOGO_COLORS
gr(show = false, size = (400, 400))
Revise.track(DirectSearch)


#
function OKA1(x)

    # y variable
    y = zeros(2);
    y[1] = cos(pi/12) * x[1] - sin(pi/12) * x[2];
    y[2] = sin(pi/12) * x[1] + cos(pi/12) * x[2];

    # functions
    f1 = y[1];
    f2 = sqrt(2*pi) - sqrt(abs(y[1])) + 2 * abs(y[2] - 3 * cos(y[1]) - 3)^(1/3);

    return [f1;f2]

end
m=2
function F1(x)
    f1(x)=OKA1(x)[1]
    f2(x)=OKA1(x)[2]
    return [f1,f2]
end

p = DSProblem(m; objective=F1,initial_point=[2,2], iteration_limit=100000,full_output=false);
# AddStoppingCondition(p, HypervolumeStoppingCondition(4.13))
# AddStoppingCondition(p, RuntimeStoppingCondition(4.1320))
SetFunctionEvaluationLimit(p,10000000)

# SetVariableRange(p,1,0.,0.19
cons1(x) = 6*sin(pi/12) < x[1] < 6*sin(pi/12)+2*pi*cos(pi/12)
AddExtremeConstraint(p, cons1)
cons2(x) = -2*pi*sin(pi/12) < x[2] < 6*cos(pi/12)
AddExtremeConstraint(p, cons2)
# for i=1:m
#     cons(x) = (-4. <= x[i] <=6*sin(pi/12)+2*pi*cos(pi/12); 6*cos(pi/12))
#     AddExtremeConstraint(p, cons)
# end
# x <= [6*sin(pi/12)+2*pi*cos(pi/12); 6*cos(pi/12)]
# x >= [6*sin(pi/12); -2*pi*sin(pi/12)]
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
savefig(fig, "./test_functions/pareto_result/OKA1.pdf")
