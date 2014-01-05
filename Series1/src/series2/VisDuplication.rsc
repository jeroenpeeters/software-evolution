module series2::VisDuplication

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

public loc smallsql     = |project://smallsql0.21_src/|;
public loc hsqldb       = |project://hsqldb-2.3.1/|;
public loc simplejava   = |project://SimpleJava/|;

private int MINIMUM_CLONE_BLOCK = 6;
private str CLASS_COLOR = "green";
private str CLONE_COLOR ="orange";

private	str CLONE_DESCRIPTION =	"Orange=clone\nGreen=associated file (clickable)";

//start here: example visualizeClones(|project://SimpleJava/|); 
public void visualizeClones(loc project) {
	int startTime = getMilliTime();
	
	map[list[str], set[loc] ] clones=	findClones(project);
	
	list[Figure] visibleObjectsToDraw = [];
	
	for(clone <- clones ){
		int cloneSize = size(clone);
		cloneEllipse = ellipse(NO_BORDER, size( cloneSize * 3 ), fillColor("orange"));
		
		//list[Figure]
		cloneReferences = for(decl <- clones[clone])
			append createFigureForClass(clone, decl, cloneSize * 2);
		
		cloneTree = tree (cloneEllipse, cloneReferences,
			std(size(50)), std(gap(20)), manhattan(false) );
		
		visibleObjectsToDraw+= cloneTree;
	}
	
	visibleObjectsToDraw = makeProjectSummary(project, clones) +  visibleObjectsToDraw;
	
	render( vcat( visibleObjectsToDraw, gap(50)) );
	
	println("It took <(getMilliTime()-startTime)/1000> seconds to calculate and visualize duplicates.");
}

private map[list[str], set[loc] ] findClones(loc project){
	M3 m3 = createM3FromEclipseProject(project);
	
	comments = {};
	for(<_,line> <- m3@documentation){
		comments += toSet(readFileLines(line));
	}
	
	ast = createAstsFromEclipseProject(project, false);
	
	return findClonesByMap(ast, 6, comments);
} 

private Figure createFigureForClass(list[str] clonedLines, loc location, int figSize){
	return ellipse(	NO_BORDER,
					size(15), 
					fillColor(CLASS_COLOR),  
					onMouseDown( openLocation(location) )
				);
}

private list[Figure] makeProjectSummary(loc project, map[list[str], set[loc] ] clones) {
	int mapSize =0;
	
	list[loc] allLocations = [];
	for(clone <- clones){
		mapSize+=1;
		allLocations += toList(clones[clone]); 
	}
	
	int perc = round(getClonePercentage());
	
	list[str] projectDetails = ["We found <mapSize> place(s) in this project,\nwhich is good for <perc>% duplication,\nspread over <size(allLocations)> files.", CLONE_DESCRIPTION];
	
	return makeTextBox("Summary of Duplications for <project>", projectDetails);
}

private list[Figure] makeTextBox(str title, list[str] messages){
	visMessages = for(message <- messages) 
		append  text(message, fontColor("black"), fontSize(10), left());
	
	visMessages = [text(title, fontColor("green"), fontSize(16), left())] + visMessages;
	
	return [vcat(visMessages, std(gap(10)), left())];
}