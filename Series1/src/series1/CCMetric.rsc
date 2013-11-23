module series1::CCMetric

import lang::java::m3::AST;
import series1::utils;

@doc{
SIG Model; Complexity per unit
Computes the Cyclomatic Complexity per method and returns a list of relations where the first item 
of the relation is the complexity number, the second the the fully qualified method name, and the third a link to the code (loc)
}
public lrel[int, str, loc] ccPerUnit(set[Declaration] ast){
    return for(/compilationUnit(package, _, /class(className, _,_, /m:method(_, name, _, _, s) )) <- ast)
        append <cc(s), "<fqPackageName(package)>.<className>#<name>", m@src>;
}

@doc{
Selects the methods with a minimal cyclomatic complexity of mincc.
}
public lrel[int, str, loc] minCC(int mincc, lrel[int, str, loc] cclist){
	return [cc | cc <- cclist, cc[0] >= mincc];
}

@doc {
Computes the complexity of the given sub-AST.
Complexity increases for the following: break, case, catch, continue, do-while, foreach, for, if, if-else, throw, while, 
return that is not the last statement and for boolean expressions (&&, ||).
}
private int cc(Statement stmnt){
    int i = 1;
    int retCount = -1;
    visit(stmnt){
    	case \return(): retCount += 1;
    	case \return(_): retCount += 1;
    	case \break(): i += 1;
    	case \break(_): i+= 1;
    	case \case(_): i += 1;
    	case \catch(_,_): i += 1;
    	case \continue(): i += 1;
    	case \continue(_): i+= 1;
    	case \do(_,_): i += 1;
    	case \foreach(_,_,_): i += 1;
    	case \for(_,_,_,_): i += 1;
    	case \for(_,_,_): i += 1;
    	case \if(Expression condition, Statement thenBranch, Statement elseBranch): i += 1;
    	case \if(Expression condition, Statement thenBranch): i += 1;
    	case \infix(_,"||",_,_): i += 1;
    	case \infix(_,"&&",_,_): i += 1;
    	case \throw(_): i += 1;
    	case \while(_,_): i += 1;
    }
    retCount = retCount == -1 ? 0 : retCount;
    return i + retCount;
}
