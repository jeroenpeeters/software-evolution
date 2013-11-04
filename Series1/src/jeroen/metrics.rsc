module jeroen::metrics

import IO;

import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;

public loc smallsql 	= |project://smallsql0.21_src/|;
public loc hsqldb 		= |project://hsqldb-2.3.1/|;
public loc helloworld 	= |project://HelloWorld/|;

public void computeMetricsForProject(loc project){
	ast = createAstsFromEclipseProject (project, false);
	
	println("LoC: <locMetric(ast)>");
}

public int locMetric(set[Declaration] ast){
	int l = 0;
	visit(ast){
		/* Declarations */
		case parameter(_,_,_)			: ;
		case varargs(_,_)				: ;
		case package(_)					: ;
		case package(_,_)				: ;
		case Declaration d				: l += 1;
		
		/* Statements */
		case block(_)					: ;
		case Statement s				: l = l + 1;
	}
	return l;
}
