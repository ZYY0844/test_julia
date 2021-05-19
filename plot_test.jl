# using Revise
# using Plots,SymPy,LaTeXStrings



function s(x::Float64)
    return abs(floor(x + 1 / 2) - x)
end

function f(w::Float64, x::Float64)
    Taka = 0;
    for n in 1:100
        Taka += w^n * s(2^n * x)
    end
    return Taka
end

fig = plot(); # produces an empty plo;
for w = [0.1, 0.25,0.5,0.75,0.9] # the for loop
    plot!(fig, [-f(w, x) for x ∈ 0:0.0001:0.25]) # the loop fills in the plot with this
end
plot(fig, label=[L"w=0.1" L"w=0.25" L"w=0.5" L"w=0.75" L"w=0.9"],
    fg_legend=:transparent, legend=:topleft) # just produces the plot
display(fig)




