module series1::series1

import IO;
import List;

import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import series1::CCMetric;

public loc smallsql     = |project://smallsql0.21_src/|;
public loc hsqldb       = |project://hsqldb-2.3.1/|;
public loc simplejava   = |project://SimpleJava/|;

public set[Declaration] astSimple 	 = createAstsFromEclipseProject(simplejava, false);
public set[Declaration] astSql		 = createAstsFromEclipseProject(smallsql, false);

public void series1(loc project){
	ast = createAstsFromEclipseProject(project, false);
	
	println("## Cyclomatic complexity per unit ##");
	ccList = ccPerUnit(ast);
	for(cc <- reverse(sort(ccList))){
		println("<cc[0]> :: <cc[1]> :: (<cc[2]>)");
	}
	println("Number of methods with minimal CC of 10 is <size(minCC(10,ccList))>");
}