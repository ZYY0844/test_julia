using DirectSearch
Revise.track(DirectSearch)

# include("/Users/zyy/.julia/dev/DirectSearch/src/DirectSearch.jl")
# using .DirectSearch_test
# import("Direct")
# using Plots
# using Gadfly
# using GR
function s(x)
    return abs(floor(x + 1 / 2) - x)
end

function f(x::Vector{Float64},test=6)
    Taka = 0
    w = 0.9
    test=4
    for n in 1:100
        Taka -= w^n * s(2^n * x[1])
    end
    return Taka
end

function phi(f1::Function,f2::Function, r::Vector{Float64}, x::Vector{Float64})

    if (f1(x) <= r[1]) && (f2(x) <= r[2]) #if x dominant r
        return -(r[1] - f1(x))^2 * (r[2] - f2(x))^2
    else
        return (max(f1(x) - r[1], 0))^2 + (max(f2(x) - r[2], 0))^2
    end
end

function test1(x)
f1(x) = (x[1]+2).^2 - 10. + (x[2]-3).^2
f2(x) = (x[2]-2).^2 + 20. + (x[1]+1).^2
# f3(x)=(1-x[1])
return [f1,f2]
end
# test1.f1([1,2])

function ex005(x)
    obj(x) = x'*[2 1;1 4]*x + x'*[1;4] + 7;
    return [obj]
end

obj(x) = (x[1] + 1) .^ 2 +(x[2] - 1) .^ 4- 20.0
obj2(x) = (x[1] + 1) .^ 2 +(x[2] - 4) .^ 4
obj3(x)= (x[1] + 2) .^ 2  - 10.0
f_reform(x)=phi(obj,obj2, [1.,1.], x)


p = DSProblem(2; objective=ex005, initial_point=[1.,0.],iteration_limit=1000,full_output=false);
# AddStoppingCondition(p, HypervolumeStoppingCondition(1.2))
# p = DSProblem(1; objective=f, initial_point=[-7.5],full_output=true);
# SetFunctionEvaluationLimit(p,1000000)
# SetVariableRange(p,1,0.,0.19)
# cons1(x) = x[1] > -10.
# AddExtremeConstraint(p, cons1)
# cons2(x) = x[1] <-5
# AddExtremeConstraint(p, cons2)
function p_MADS(p::DSProblem)
    x = zeros(Float64, p.N)
    f= p.objective(x)
    SetObjective(p, f[1])
end

# p_MADS(p)

# AddStoppingCondition(p, ButtonStoppingCondition("quit"))
# SetIterationLimit(p,2)
# AddStoppingCondition(p, RuntimeStoppingCondition(0.01))
# SetRuntimeLimit(p, 0.2)

# testbi(p)
# p_dim(p)
Optimize!(p)
# @show p.status
# @show p.x
# @show p.x_cost
# @show p.status.iteration

function pareto_front(points, minimize = true)
    cmp_strict = minimize ? (<) : (>);
    cmp = minimize ? (<=) : (>=);
    dims = size(points,2)
    strictly_dominates(u, v) = all(cmp(u[i], v[i]) for i = 1:dims+1) && any(cmp_strict(u[i], v[i]) for i = 1:dims+1)
    undominated(p) = !any(strictly_dominates(p2, p) for p2 ∈ points if p2 != p)
    front = filter(undominated, points)
    sort(front)
    display(front)
end
