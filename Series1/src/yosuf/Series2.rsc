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

import Utils;
import series1::series1;
import series1::VolumeMetric;
import series1::CCMetric;
import series1::DuplicationMetric;


public loc smallsql     = |project://smallsql0.21_src/|; //bechnmark: 18seconds
public loc hsqldb       = |project://hsqldb-2.3.1/|; // benchmark: 2min32sec
public loc simplejava   = |project://SimpleJava/|; // benchmark: <1sec
//public loc viz   = |project://scrumviz/|; // benchmark: <1sec

public set[Declaration] ast = createAstsFromEclipseProject(smallsql, false);


/**
* Returns the metrics for classes and interfaces:
* - sloc
* - max cc ranking
* - fqdn
* - location
*/
public lrel[int, int, str, loc] getMetricsForAst(set[Declaration] ast){
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
  
  if(size(cc)>0){
    return max(cc.ucc);
  } else {
    return 0;
  }
}

//TODO YH
private int slocForLoc(){
	return 0;
}

public void visualise(){
   lrel[int sloc, int cc,str fqdn,loc ref] relations = getMetricsForAst(ast);
   
   for(<int sloc, int cc,str fqdn,loc ref> <- relations) {
     println("cc: <cc>");
    
   }
   
   println("Relations are:\n <size(relations)> \n.End of Relations");
   
   	render( 
   	  hcat( 
   	       [ box( onMouseDown( openLocation(relations[i].ref) ), 
   	              lineWidth(0.8),
   	              fillColor( determineComplexityColor(relations[i].cc) )
   	            ) | i <- [0..size(relations)]       
   	       ] 
   	      )        
   	 );
}



public void visTree(){

	ellipse1 = ellipse(NO_BORDER,size(80), fillColor(duplicationColor(3)));
	tree1 = tree (
		ellipse1,
		[createClassFig(), createClassFig()],
		std(size(50)), std(gap(20)), manhattan(false)
	);
	

	ellipse2 = ellipse(NO_BORDER, size(150), fillColor(duplicationColor(2)));		
	tree2 = tree (
		ellipse2,
		[createClassFig(), createClassFig(),createClassFig(),createClassFig(), createClassFig()],
		std(size(50)), std(gap(20)), manhattan(false)
	);
	
	
	render( hcat([
			 tree1,
			 tree2
			])
	 );
	
}

private Figure createClassFig(Declaration d){
	FProperty CLASS_REL_SIZE = size(40);
	return ellipse(NO_BORDER, CLASS_REL_SIZE, fillColor("green"),  onMouseDown( openLocation(d@src) ) );
}

public void visClones() {

	loc project=smallsql;//|project://SBG-JAXB/|;
	M3 m3 = createM3FromEclipseProject(project);
	
	comments = {};
	for(<_,l> <- m3@documentation){
		comments += toSet(readFileLines(l));
	}

	ast = createAstsFromEclipseProject(project, false);
	map[list[Line], set[Declaration] ] clones=	findFilteredClones(ast, 6, comments);
	
	list[Figure] visibleClones = [];
	
	for(clone <- clones ){
	
		cloneSize = size( clones[clone] );
		println("cloneSize: <cloneSize>");
		
		ellipse0 = ellipse(NO_BORDER, size(150), fillColor(duplicationColor(cloneSize)));
		
		list[Figure] cloneReferences = [];
		
		for(d <- clones[clone]){
			cloneReferences+= createClassFig(d);
		}
		
		treeArch = tree (
			ellipse0,
			cloneReferences,
			std(size(50)), std(gap(20)), manhattan(false)
		);
		
		visibleClones+= treeArch;
		
	}
	
	render( vcat( visibleClones ) );
}