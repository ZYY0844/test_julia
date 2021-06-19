

using Revise
using Plots,SymPy,LaTeXStrings


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


fig = plot();
for w = [0.1, 0.25,0.5,0.75,0.9]
    # plot!(fig, [-f(w, x) for x ∈ 1.2-0.0001:0.0001:1.2+0.0001])
    plot!(fig, [-f(w, x) for x ∈ 0.:0.0001:0.25])
end
plot(fig, label=[L"w=0.1" L"w=0.25" L"w=0.5" L"w=0.75" L"w=0.9"],
    fg_legend=:transparent, legend=:topleft)
display(fig)

savefig(fig, "taka.pdf");
