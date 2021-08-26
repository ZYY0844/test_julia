using DirectSearch
using Plots
using Statistics
logocolors = Colors.JULIA_LOGO_COLORS
gr(show = false, size = (400, 400))
Revise.track(DirectSearch)


# f1(x)=4* x[1]
# function g(x)
#     return (0. <=x[2]<=0.4)*(4-3*(exp(-(x[2]-0.2)/0.02))^2)+(0.4 <x[2]<=1)*(4-2*(exp(-(x[2]-0.7)/0.2))^2)
# end

function dt2(x)
    # m=10
    f1(x)= x[1]
    g(x)=1+10*x[2]
    h(x)=1-(f1(x)/g(x))^2-f1(x)/g(x)*sin(8*pi*f1(x))
    f2(x)=g(x)*h(x)
    return [f1,f2]
end
 # for i=0:0.01:0.5
 #     @show f2([06,i])
 # end

p = DSProblem(2; objective=dt2,initial_point=[0.51,0.51], iteration_limit=100000,full_output=false);
# AddStoppingCondition(p, HypervolumeStoppingCondition(1.4464))
# AddStoppingCondition(p, RuntimeStoppingCondition(3.5))
SetFunctionEvaluationLimit(p,10000000)

# SetVariableRange(p,1,0.,0.19)
# cons1(x) = 0. < x[1] < 1.
# AddExtremeConstraint(p, cons1)
for i=1:2
    cons(x) = 0. < x[i] <1.
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
    fig=scatter!([result[i].cost[1]],[result[i].cost[2]],color=logocolors.red,legend = false,poll=OrthoMADS())
end

plot!(fig,xlabel="f1 cost",ylabel="f2 cost")
display(fig)
# savefig(fig, "./test_functions/pareto_result/dt2.pdf")
