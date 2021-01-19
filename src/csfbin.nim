import csf
import sequtils, tables, strformat


when isMainModule:

    proc isSatisifiedWith[V,D](this: Constraint[V,D], assignment: Table[V,D]): bool =
        let r1 = this.variables[0]
        let r2 = this.variables[1]

        echo &">>>>> r1 {r1}, r2 {r2} assignment {assignment}"
        if r1 notin assignment:
            return true
        if r2 notin assignment:
            return false
        return assignment[r1] != assignment[r2]

    proc initMapColorConstraint[V,D](variables: seq[V]) : Constraint[V,D] = 
        return Constraint[V,D](variables:variables, satisfyFunc: isSatisifiedWith[V,D])

    let variables = @["Western Australia", "Northern Territory", "South Australia", "Queensland", "New South Wales", 
    "Victoria", "Tasmania"]
    let domainVals = @["red", "blue", "green"]

    var domains = initTable[string, seq[string]]()
    for v in variables:
        echo &"setting {v} to {domainVals}"

        domains[v] = domainVals
    var csp = newCSF[string, string](variables, domains)

    let neighborsPairs = @[
            ["Western Australia", "Northern Territory"],
            ["Western Australia", "South Australia"],
            ["South Australia", "Northern Territory"],
            ["Queensland", "Northern Territory"],
            ["Queensland", "South Australia"],
            ["Queensland", "New South Wales"],
            ["New South Wales", "South Australia"],
            ["Victoria", "South Australia"],
            ["Victoria", "New South Wales"],
            ["Victoria", "Tasmania"], 
    ]
    for pair in neighborsPairs:
        let constraint = initMapColorConstraint[string, string](variables= @[pair[0], pair[1]])
        csp.addConstraint(constraint)



    echo $csp.backtrack()
    # echo $csp.constraints