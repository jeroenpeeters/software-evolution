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
import Utils;
import series1::CCMetric;


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
	box1 = box(size(40), fillColor("green"));
	box2 = box(size(40), fillColor("blue"));
	
	ellipse1 = ellipse(size(80), fillColor(duplicationColor(2)));
		
	tree1 = tree (
		ellipse1,
		[box1, box2],
		std(size(50)), std(gap(20)), manhattan(false)
	);
	

	box3 = box(size(40), fillColor("green"));
	box4 = box(size(40), fillColor("blue"));
	
	ellipse2 = ellipse(size(80), fillColor(duplicationColor(3)));
		
	tree2 = tree (
		ellipse2,
		[box3, box4],
		std(size(50)), std(gap(20)), manhattan(false)
	);
	
	
	render( hcat([
			 tree1,
			 tree2
			])
	 );
	
	
//	t2 = tree(box(fillColor("green")),
//          [ box(fillColor("red")),
//     	    box(fillColor("blue"))
//     	  ],
//          std(size(50)), std(gap(20)), manhattan(false)
//    	);
//render(t2);
	
}
