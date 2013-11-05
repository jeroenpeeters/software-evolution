@contributor{Jeroen Peeters - jeroen@peetersweb.nl}
module jeroen::metrics

import IO;

import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;

public loc smallsql     = |project://smallsql0.21_src/|;
public loc hsqldb       = |project://hsqldb-2.3.1/|;
public loc helloworld   = |project://HelloWorld/|;

data Rank = pp() | p() | n() | m() | mm();

@doc{
Computes metrics for the given Eclipse Project
}
public void computeMetricsForEclipseProject(loc project){
    ast = createAstsFromEclipseProject (project, false);
    
    println("LoC: <locMetric(ast)>
    		 'Rank Man Year Via Backfiring Function Points: <rankMyBackfiringFp(ast)>");
}

@doc{
SIG Model; Volume; Lines of code
}
public int locMetric(set[Declaration] ast){
    int l = 0;
    visit(ast){
        /* Declarations */
        case parameter(_,_,_)   : ;
        case varargs(_,_)       : ;
        case package(_)         : ;
        case package(_,_)       : ;
        case Declaration d      : {l += 1; p(d);}
        
        /* Statements */
        case block(_)           : ;
        case Statement s        : {l += 1; p(s);}
    }
    return l;
}

@doc{
SIG Model; Volume; Man years via backfiring function points
}
public Rank rankMyBackfiringFp(set[Declaration] ast){
	kloc = locMetric(ast)/1000;
	if(kloc < 66){
		return pp();
	} else if(kloc >= 66 && kloc < 246){
		return p();
	} else if(kloc >= 246 && kloc < 665){
		return n();
	} else if(kloc >= 665 && kloc < 1310){
		return m();
	} else {
		return mm();
	}
	
}

@doc{
SIG Model; Complexity per unit
}
public void cyclomaticComplexityPerUnit(set[Declaration] ast){
	
}

/*
 * Private section from here on
 */

@doc{
Prints a node, this method is used to centralize switching output on or off.
}
private void p(node n){
    //println(n); // comment-out to turn output off
}