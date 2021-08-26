using Revise
using Plots, SymPy, LaTeXStrings, BenchmarkProfiles
using ParetoRecipes
logocolors = Colors.JULIA_LOGO_COLORS
gr(show = false, size = (500, 400))
# function s(x::Float64)
#     return abs(floor(x + 1 / 2) - x)
# end
#
# function f(w::Float64, x::Float64)
#     Taka = 0;
#     for n in 1:100
#         Taka += w^n * s(2^n * x)
#     end
#     return Taka
# end
# fig = plot();
# for w = [0.1, 0.25,0.5,0.75,0.9]
#     # plot!(fig, [-f(w, x) for x ∈ 1.2-0.0001:0.0001:1.2+0.0001])
#     plot!(fig, [-f(w, x) for x ∈ 1.2-0.0001:0.0001:1.2+0.0001])
# end
# plot(fig, label=[L"w=0.1" L"w=0.25" L"w=0.5" L"w=0.75" L"w=0.9"],
#     fg_legend=:transparent, legend=:topleft)
# display(fig)
#
# savefig(fig, "taka.pdf")
result = [[2, 2], [2, 3], [3, 3], [0.5, 4], [4, 0.5], [1, 1], [1, 2]]
# fig=scatter()
# for i in 1:6
#     fig=scatter!([result[i][1]],[result[i][2]],color=logocolors.blue,legend = false)
# end
# plot!(fig,xlabel="f1",ylabel="f2",xticks=[],yticks=[])
# display(fig)
# fig=pareto([[1.8, 1.8], [0.3, 2.3], [2.5, 1], [0.5, 4], [3.5, 0.2], [1, 1],
# [1,2],[1.2,2.1],[2,0.5],[1.2,1.5],[0.2,3.5],[3,0.4],[1,3],[0.7,1.5],[1.7,0.8],[1.8,1.1],[0.6,2.9],
# [2.4,0.8],[2.6,0.9]])
# # pareto([[1, 0], [0, 1], [1, 1], [2, 2]])
# plot!(fig,xlabel="f2",ylabel="f2",xticks=[],yticks=[],linewidth=3)
# display(fig)
#  savefig(fig, "./temp_fig/pareto_example.pdf")

T = rand(20, 2);

time = [
5.3835	480
6.630850792	511
0.7473	394
7.2163898	309
3.57	420
1.9232	48
1.8163	16
1.54	17
0.371229	18
0.386	15
0.2631	17
1.90423	22
1.189	123
0.4121	45
0.85318	102
0.4995181	43
0.2143831	32
7.0209788	92
4.801607	89
1.03238188	34
    ]

bb_eval = [
82099.	4524.0
34795	5323
86819	4198
104106	3302
63502	3879
29719	1207
18398	407
18228	402
5880	632
12758	617
11291	609
21694	1205
28493	2391
8913	870
23297	1654
5350	625
5116	607
92591	1728
42789	5168
4902	626
]

for i = 1:20
    T[i, 1] = a[1, i]
    T[i, 2] = a[2, i]
end
time_fig=performance_profile(
    PlotsBackend(),
    time,
    ["Solver 1", "Solver 2"],
    legend = :bottomright,
    linewidth=2
)

bb_fig=performance_profile(
    PlotsBackend(),
    bb_eval,
    ["Solver 1", "Solver 2"],
    legend = :bottomright,
    linewidth=2
)
savefig(time_fig, "./test_functions/time_perfom.pdf")
savefig(bb_fig, "./test_functions/bb_perfom.pdf")
