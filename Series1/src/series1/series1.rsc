module series1::series1

import IO;
import List;

import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import series1::CCMetric;

public loc smallsql     = |project://smallsql0.21_src/|;
public loc hsqldb       = |project://hsqldb-2.3.1/|;
public loc helloworld   = |project://HelloWorld/|;

public set[Declaration] astH = createAstsFromEclipseProject(helloworld, false);
public set[Declaration] astS = createAstsFromEclipseProject(smallsql, false);

public void series1(loc project){
	ast = createAstsFromEclipseProject(project, true);
	
	println("## Cyclomatic complexity per unit ##");
	for(cc <- reverse(sort(ccPerUnit(ast)))){
		println("<cc[0]> :: <cc[1]> :: (<cc[2]>)");
	}
}