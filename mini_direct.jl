using DirectSearch

function s(x)
    return abs(floor(x + 1 / 2) - x)
end

function f(x)
    Taka = 0
    w = 0.9
    for n in 1:100
        Taka -= w^n * s(2^n * x[1]) 
    end
    return Taka
end
# obj(x)=-f

p = DSProblem(1; objective=f, initial_point=[0.10]);

Optimize!(p)

@show p.status
@show p.x
@show p.x_cost