using DirectSearch, Plots, DataFrames, DelimitedFiles, LinearAlgebra, Statistics
logocolors = Colors.JULIA_LOGO_COLORS

gr(show = false, size = (400, 400))

function paretoCoverage(result::Matrix{Float64},row::Int)
    points=Vector{Float64}()
    for i=1:row-1
        push!(points,LinearAlgebra.norm(result[i+1,1:2] - result[i,1:2])^2)
    end
    return mean(points), std(points)
end

function hvIndicator(result::Matrix{Float64},row::Int,factor=1.1)::Float64
    points=Vector{Vector{Float64}}()
    for i=1:row-1
        push!(points,result[i+1,1:2])
    end
    length(points)<2 && return 0.
     ref=factor.*[last(points)[1],first(points)[2]]
     normalize_factor=(ref[1]-first(points)[1]).*(ref[2]-last(points)[2])./2
     hv_volume=0.
     area(x::Vector{Float64},y::Vector{Float64})=(abs(x[1]-y[1])).*(abs(x[2]-y[2]))
     for p in points
         hv_volume+=area(ref,p)
         ref[2]=p[2]
     end
     return hv_volume/normalize_factor
end

df = readdlm("./front.0.txt")
@show row=Int(length(df)/2)

result=reshape(df,row,2)
@show length(result)/2
@show paretoCoverage(result,row)
@show hvIndicator(result,row)
fig=scatter()
for i in 1:row
    fig=scatter!([result[i,1]],[result[i,2]],color=logocolors.blue,legend = false)
end
plot!(fig,xlabel="f1 cost",ylabel="f2 cost")
display(fig)
# savefig(fig, "./test_functions/pareto_result/FAR1_NOMAD.pdf")
#
