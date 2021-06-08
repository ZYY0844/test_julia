using DirectSearch

p = DSProblem(3);
obj(x) = x'*[2 1;1 4]*x;
p = DSProblem(2; objective=obj, initial_point=[4,2.3]);

p = DSProblem(2)
SetInitialPoint(p, [1.0,2.0])
SetObjective(p,obj)
SetIterationLimit(p, 500)


# cons(x) = x[1] < 1.5 #Constrains x[1] to be larger than 0
# AddExtremeConstraint(p, cons)
Optimize!(p)

@show p.x
@show p.x_cost
