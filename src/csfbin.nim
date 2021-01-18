import csf
import sequtils, tables, strformat


when isMainModule:

    
    type MapColorConstraint[K,V] = object of Constraint[K,V]
        r1*: string
        r2*: string

    proc initMapColorConstraint[K,V](r1, r2: string): MapColorConstraint[K,V] =
        
        result = MapColorConstraint[K,V](r1:r1, r2:r2, variables: @[r1,r2])
    
    proc isSatisifiedWith[K,V](this: MapColorConstraint[K,V], assignment: Table[K, V]): bool =
        echo &"this.r1 {this.r1}, this.r2 {this.r2} assignment {assignment}"
        if this.r1 notin assignment:
            return true
        if this.r2 notin assignment:
            return false
        return assignment[this.r1] != assignment[this.r2]
        

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
        let constraint = initMapColorConstraint[string, string](pair[0], pair[1])
        csp.addConstraint(constraint)



    echo $csp.backtrack()
    echo $csp.constraints