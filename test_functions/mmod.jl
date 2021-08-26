using DirectSearch
using Plots
using Statistics
logocolors = Colors.JULIA_LOGO_COLORS
gr(show = false, size = (400, 400))
Revise.track(DirectSearch)

function mmod(x)
    m=10
    f1(x)=x[1]
    g(x)=1+10*(m-1) + sum((x[2:m]) .^ 2 .- 10 .* cos.(4 .* pi .* x[2:m]))
    h(x)=1-sqrt(f1(x)/ g(x))
    f2(x)=g(x)*h(x)
    return [f1,f2]
end

p = DSProblem(10; objective=mmod,initial_point=ones(10)./2, iteration_limit=100000,full_output=false);
# AddStoppingCondition(p, HypervolumeStoppqingCondition(1.4464))
# AddStoppingCondition(p, RuntimeStoppingCondition(3.5))
SetFunctionEvaluationLimit(p,10000000)

# SetVariableRange(p,1,0.,0.19)
cons1(x) = 0. < x[1] < 1.
AddExtremeConstraint(p, cons1)
for i=2:10
    cons(x) = -5. < x[i] <5.
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
savefig(fig, "./test_functions/pareto_result/mmod_1.pdf")
