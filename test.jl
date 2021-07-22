# using DirectSearch
# using Plots

# if readline()=nothing
#     println("nothing")
# else
#     println()
#
# input = ""
# @async while true
#     global input = readavailable(stdin)
#     if !isempty(input)
#         break
#     end
# end


# while true # some long-running computation
#     if !isempty(input)
#         break
#     else
#         println("ddd")
#     end
#     # do some other work here
# end



import REPL



function check()
        bb = bytesavailable(stdin)
        if bb>0
            println("quit")
            return 1
        end
end
function test()
    term = REPL.Terminals.TTYTerminal("xterm",stdin,stdout,stderr)
    REPL.Terminals.raw!(term,true)
    Base.start_reading(stdin)
    while true
        println("qwe")
        # sleep(3)
        if check()==1
            println("asd")
            return
        end

    end
end
# # p = DSProblem(3);
# obj(x) = x'*[2 1;1 4]*x;
# p = DSProblem(2; objective=obj, initial_point=[4,2.3],full_output=true);
#
# p = DSProblem(2)
# SetInitialPoint(p, [1.0,2.0])
# SetObjective(p,obj)
# SetIterationLimit(p, 500)
#
#
# cons(x) = x[1] < 1.5 #Constrains x[1] to be larger than 0
# AddExtremeConstraint(p, cons)
# Optimize!(p)
#
# @show p.x
# @show p.x_cost
