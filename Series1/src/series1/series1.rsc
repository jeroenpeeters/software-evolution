module series1::series1

import IO;
import List;

import lang::java::jdt::m3::AST;
import lang::java::m3::AST;

import series1::CCMetric;
import series1::VolumeMetric;
import series1::DuplicationMetric;
import series1::Rank;

public loc smallsql     = |project://smallsql0.21_src/|;
public loc hsqldb       = |project://hsqldb-2.3.1/|;
public loc simplejava   = |project://SimpleJava/|;

public set[Declaration] astSimple 	 = createAstsFromEclipseProject(simplejava, false);
public set[Declaration] astSql		 = createAstsFromEclipseProject(smallsql, false);

public void series1(loc project){
	ast = createAstsFromEclipseProject(project, false);
	
	int totalSloc = sloc(ast);
	println("\n## Volume ##");
	println("Total SLOC: <totalSloc>");
	
	println("SLOC per unit:");
	slocList = slocPerUnit(ast);
	for(a <- reverse(sort(slocList))){
		println("<a[0]> :: <a[1]> :: (<a[2]>)");
	}
	
	println("\n## Cyclomatic complexity per unit ##");
	ccList = ccPerUnit(ast);
	for(cc <- reverse(sort(ccList))){
		println("<cc[0]> :: <cc[1]> :: (<cc[2]>)");
	}
	println("Number of methods with minimal CC of 10 is <size(minCC(10,ccList))>");
	
	real duplicationPrcnt = duplication(ast, 6, 6);
	println("\n## Duplication ##");
	println("%: <duplicationPrcnt>");
	
	println("\n## Summary ##");
	println("Total SLOC : <rankSloc(totalSloc)>");
	println("Duplication: <rankDuplication(duplicationPrcnt)>");
}