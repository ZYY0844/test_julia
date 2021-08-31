using  Plots

logocolors = Colors.JULIA_LOGO_COLORS
gr(show = false, size = (500, 400))

result = [
    [1.740694569909919, 0.004296767402026843],
    [1.7417687236440276, 0.0042930820525685],
    [1.7543735728347578, 0.004291074787029342],
    [1.8008510990578937,0.004289965110630173],
    [1.8890603895556883, 0.004287382076502],
    [2.5879840594943966,0.004285656181],
    [17.86, 0.004141040680085014]
]
fig=scatter()
for i in 1:7
    fig=scatter!([result[i][1]],[result[i][2]],color=logocolors.blue,legend = false)
end
plot!(fig,xlabel="Integrated absolute error",ylabel="Maximum sensitivity",formatter = :plain)
display(fig)
 savefig(fig, "./temp_fig/pareto1.pdf")
