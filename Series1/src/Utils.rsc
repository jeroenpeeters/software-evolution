module Utils

import List;
import Set;
import vis::Figure;
import vis::Render;
import util::Math;

import IO;
import vis::KeySym;
import util::Editors;

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;

@doc{
Produces the Fully Qualified package name as a string by recursively unfolding the package nodes in the AST.
}
public str fqPackageName(package(str name)) = name;
public str fqPackageName(package(Declaration parent, str name)) = "<fqPackageName(parent)>.<name>";


@DOC{
This function determines the color for a given cyclomatic complexity.
The colors generated start from 1 for green to 50 for red and orange-ish for in between.
CC above 50 remains red.

pram: 1 or higher}
public Color determineComplexityColor(int cc){
	//credit for example goes to: http://stackoverflow.com/questions/340209/generate-colors-between-red-and-green-for-a-power-meter
	return rgb( toInt((255*cc)/45) , toInt((255*(45-cc))/100), 0);
}

@DOC{
 Creates a few visual boxes to see the CC colors.
}
public void testColorForCC(){
	render( hcat( [ box(fillColor( determineComplexityColor(i) )) | i <- [1..50] ] ) );
}

public bool (int, map[KeyModifier, bool]) openLocation(loc ref) = 
	  bool (int butnr, map[KeyModifier, bool] modifiers) {
		  edit(ref);
		  return true;
	};
	
public set[str] readComments(loc project) = readComments(createM3FromEclipseProject(project));
	
public set[str] readComments(M3 m3){
	comments = {};
	for(<_,l> <- m3@documentation){
		comments += toSet(readFileLines(l));
	}
	return comments;
}