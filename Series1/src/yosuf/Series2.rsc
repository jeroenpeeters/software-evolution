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
import util::Benchmark;
import Prelude::Map;

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

private	str CLONE_DESCRIPTION =	"Orange=clone\nGreen=associated file (clickable)\nThe size of the clones represent the relative clone size between the clones.";
	

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

private Figure createClassFig(list[str] clonedLines, loc location, int figSize){
	str toPrint = "\nClonedLines\n <clonedLines>\nDeclarations\n<location>";
	
	return ellipse(	NO_BORDER,
					size(15), 
					fillColor("green"),  
					onMouseDown( openLocation(location) )
				);
}

private map[list[str], set[loc] ] findClones(loc project){
	M3 m3 = createM3FromEclipseProject(project);
	
	comments = {};
	for(<_,line> <- m3@documentation){
		comments += toSet(readFileLines(line));
	}
	
	ast = createAstsFromEclipseProject(project, false);
	map[list[str], set[loc] ] clones=	findFilteredClones(ast, 6, comments);
	
	return clones;
} 

private list[Figure] makeProjectSummary(loc project, map[list[str], set[loc] ] clones) {
	int mapSize =0;
	
	set[loc] allLocations = {};
	for(clone <- clones){
		mapSize+=1;
		allLocations += clones[clone]; 
	}
	
	list[str] projectDetails = ["Clones: <mapSize> \nFiles associated: <size(allLocations)>", CLONE_DESCRIPTION];
	
	return makeTextBox("<project> Summary of Duplications", projectDetails);
}

private list[Figure] makeTextBox(str title, list[str] messages){
	visMessages = for(message <- messages) 
		append  text(message, fontColor("black"), fontSize(10), left());
	
	visMessages = [text(title, fontColor("green"), fontSize(16), left())] + visMessages;
	
	return [vcat(visMessages, std(gap(10)), left())];
}

public void visualizeClones(loc project) {
	//loc project=|project://SBG-Core/|;
	int startTime = getMilliTime();
	
	map[list[str], set[loc] ] clones=	findClones(project);
	
	list[Figure] visibleObjectsToDraw = [];
	
	for(clone <- clones ){
		int cloneSize = size(clone);
		cloneEllipse = ellipse(NO_BORDER, size( cloneSize * 3 ), fillColor("orange"));
		
		//list[Figure]
		cloneReferences = for(decl <- clones[clone])
			append createClassFig(clone, decl, cloneSize * 2);
		
		cloneTree = tree (cloneEllipse, cloneReferences,
			std(size(50)), std(gap(20)), manhattan(false) );
		
		visibleObjectsToDraw+= cloneTree;
	}
	
	visibleObjectsToDraw = makeProjectSummary(project, clones) +  visibleObjectsToDraw;
	
	render( pack( visibleObjectsToDraw, gap(50)) );
	
	println("It took <(getMilliTime()-startTime)/1000> seconds to calculate and visualize duplicates.");
}