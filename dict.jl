using DataFrames,CSV

df = CSV.File("tempData.csv",skipto=2) |> DataFrame
dict_ref=Dict(zip(df[:,1],df[:,2]))
dict_ext=Dict(zip(df[:,1],df[:,3]))
@show df


# dict = Dict(9 => 1, 18 => 3)
# @show typeof([dict[18]])
