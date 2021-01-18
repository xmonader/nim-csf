# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import tables, strutils, options, sequtils, strformat
## Domain, Variable, Constraint
## 
## 
## 


type Constraint*[V, D] = object of RootObj
  variables*: seq[V]


proc initContstaint*[V, D](vars: seq[V]) : Constraint[V,D] = 
  result = Constraint[V,D](variables: vars)


func isSatisifiedWith*[V, D](constraint: Constraint[V,D], assignment: Table[V, D]) : bool = 
    result = true

type CSF*[V, D] = ref object 
  variables*: seq[V]
  domains*: Table[V, seq[D]]
  constraints*: TableRef[V, seq[Constraint[V,D]]]

# type CSFRef*[V, D] = ref CSF

proc newCSF*[V,D](vars: seq[V]= @[], domains: Table[V, seq[D]]=initTable[V,seq[D]]()): CSF[V, D] =
  new result
  result.variables = vars
  result.domains = domains
  var constraints = newTable[V, seq[Constraint[V,D]]]()
  for v in vars:
    # if v's domain not specified raise
    if not domains.hasKey(v):
      raise newException(Exception, $v)
    else:
      constraints.add(v, newSeq[Constraint[V,D]]())
  result.constraints = constraints
    

method addConstraint*[V, D](this: CSF, constraint: Constraint[V, D]) : void =
  for v in constraint.variables:
    if v notin this.variables:
      raise newException(Exception, &"variable {v} doesn't exist in variables list, but yet defined as constraint.")
    else:
      var theSeq = this.constraints[v]
      echo &"oldSeq {theSeq}"
      echo $constraint

      theSeq.add(constraint)
      echo &"newSeq {theSeq}"
      this.constraints[v] = theSeq


proc isConsistent*[V, D](this: CSF[V,D], v: V, assignment: Table[V, D]): bool = 
  for c in this.constraints.getOrDefault(v, @[]):
    if not c.isSatisifiedWith(assignment):
      return false
  return true

proc backtrack*[V, D](this: CSF[V,D], assignment: Table[V, D]= initTable[V,D]()): Table[V,D]

proc backtrack*[V, D](this: CSF[V,D], assignment: Table[V, D]= initTable[V,D]()): Table[V,D] = 
  echo "here" & $assignment
  if assignment.len == this.variables.len:
    return assignment
  else:
    let unassignedVars = this.variables.filterIt(not assignment.hasKey(it))
    let firstUnassigned = unassignedVars[0] 
    let varDomains = this.domains.getOrDefault(firstUnassigned, @[])
    for dom in varDomains:
      var localAssignment = deepCopy(assignment)
      echo "will assign " & firstUnassigned & " to " & dom
      localAssignment[firstUnassigned] = dom
      if this.isConsistent(firstUnassigned, localAssignment):
        echo &"{firstUnassigned} = {dom} is consistent in {localAssignment}"
        let solution = this.backtrack(localAssignment)
        if solution.len > 0:
          return solution
        else: return initTable[V, D]()
