module series1::CCMetric

import lang::java::m3::AST;
import series1::utils;

@doc{
SIG Model; Complexity per unit
Computes the Cyclomatic Complexity per method and returns a list of relations where the first item 
of the relation is the complexity number, the second the the fully qualified method name, and the third a link to the code (loc)
}
public lrel[int, str, loc] ccPerUnit(set[Declaration] ast, bool strict){
    return for(/compilationUnit(package, _, /class(className, _,_, /m:method(_, name, _, _, s) )) <- ast)
        append <cc(s, strict), "<fqPackageName(package)>.<className>#<name>", m@src>;
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
private int cc(Statement stmnt, bool strict){
    int i = 1;
    int retCount = -1;
    visit(stmnt){
    	case \return(): retCount += s(strict);
    	case \return(_): retCount += s(strict);
    	case \break(): i += s(strict);
    	case \break(_): i+= s(strict);
    	case \case(_): i += 1;
    	case \default(_): i+= s(strict);
    	case \catch(_,_): i += 1;
    	case \conditional(_,_,_): i += 1;
    	case \continue(): i += s(strict);
    	case \continue(_): i+= s(strict);
    	case \do(_,_): i += s(strict);
    	case \foreach(_,_,_): i += 1;
    	case \for(_,_,_,_): i += 1;
    	case \for(_,_,_): i += 1;
    	case \if(_,_,_): i += 1;
    	case \if(_,_): i += 1;
    	case \infix(_,"||",_,_): i += 1;
    	case \infix(_,"&&",_,_): i += 1;
    	case \throw(_): i += s(strict);
    	case \while(_,_): i += 1;
    }
    retCount = retCount == -1 ? 0 : retCount;
    return i + retCount;
}

private int s(bool b) = b ? 0 : 1;
