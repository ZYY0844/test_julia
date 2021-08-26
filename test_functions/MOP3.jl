using DirectSearch
using Plots
using Statistics
using LinearAlgebra
logocolors = Colors.JULIA_LOGO_COLORS
gr(show = false, size = (400, 400))
Revise.track(DirectSearch)

function MOP3(x)

    # params
    A1 = 0.5 * sin(1) - 2 * cos(1) + sin(2) - 1.5 * cos(2);
    A2 = 1.5 * sin(1) - cos(1) + 2 * sin(2) - 0.5 * cos(2);
    B1 = 0.5 * sin(x[1]) - 2 * cos(x[1]) + sin(x[2]) - 1.5 * cos(x[2]);
    B2 = 1.5 * sin(x[1]) - cos(x[1]) + 2 * sin(x[2]) - 0.5 * cos(x[2]);

    # functions
    f1 = -1 - (A1 - B1)^2 - (A2 - B2)^2;
    f2 = -(x[1] + 3)^2 - (x[2] + 1)^2;

    # maximization
    return -[f1;f2]

end
m=2
function F1(x)
    f1(x)=MOP3(x)[1]
    f2(x)=MOP3(x)[2]
    return [f1,f2]
end

p = DSProblem(m; objective=F1,initial_point=ones(m) ./2, iteration_limit=100000,full_output=false);
# AddStoppingCondition(p, HypervolumeStoppingCondition(4.13))
# AddStoppingCondition(p, RuntimeStoppingCondition(4.1320))
SetFunctionEvaluationLimit(p,10000000)

# SetVariableRange(p,1,0.,0.19
# cons1(x) = 0. < x[1] < 1.
# AddExtremeConstraint(p, cons1)
for i=1:m
    cons(x) = (-pi <= x[i] <=pi)
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
# savefig(fig, "./test_functions/pareto_result/MOP3_2.pdf")
