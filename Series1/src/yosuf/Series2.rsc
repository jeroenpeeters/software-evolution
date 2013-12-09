module yosuf::Series2


import IO;
import List;
import Set;
import String;
import util::Math;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import vis::Figure;
import vis::Render;
import vis::KeySym;

import util::Editors;

import series1::series1;
import series1::VolumeMetric;
import series1::utils;
import series1::CCMetric;



public loc smallsql     = |project://smallsql0.21_src/|; //bechnmark: 18seconds
public loc hsqldb       = |project://hsqldb-2.3.1/|; // benchmark: 2min32sec
public loc simplejava   = |project://SimpleJava/|; // benchmark: <1sec
public loc viz   = |project://scrumviz/|; // benchmark: <1sec

public set[Declaration] ast = createAstsFromEclipseProject(viz, false);


/**
* Returns for classes and interfaces:
* - sloc
* - max cc ranking
* - fqdn
* - location
*/
public lrel[int, int, str, loc] calculate(set[Declaration] ast){
	//These two could be done together to optimize.
	return perClass(ast)  + perInterface(ast);
}

private lrel[int, int, str, loc] perClass(set[Declaration] ast){
 	return for(/cu:compilationUnit(package, _, /c:class(className, _,_,classBody) ) <- ast)  
	     append <slocForLoc(), getHighestCcForClass(c@src), "<fqPackageName(package)>.<className>" , c@src>;	 
}

private lrel[int, int, str, loc] perInterface(set[Declaration] ast){
  return for(/cu:compilationUnit(package, _, /i:interface(interfaceName, _,_,classBody) ) <- ast)
   //for interface, we return 1 as default for comlexity since there is no implementatioin
     append <slocForLoc(), 0, "<fqPackageName(package)>.<interfaceName>" , i@src>;
}

private int getHighestCcForClass(loc classLoc) {
  ast = { createAstsFromEclipseFile(classLoc, false) } ;
  lrel[int ucc, str expr, loc location] cc = ccPerUnit(ast,false);
  return max(cc.ucc);
}

//TODO
private int slocForLoc(){
	return 0;
}

@DOC{pram: 1 or higher}
public Color determineComplexityColor(int cc){
	return rgb( toInt((255*cc)/50) , toInt((255*(65-cc))/100), 0);
}

public void testColorForCC(int cc){
	render( vcat([ box(fillColor( determineComplexityColor(cc) )) ]) );
} 


	