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


public FProperty NO_BORDER= lineWidth(0);

@doc{
Produces the Fully Qualified package name as a string by recursively unfolding the package nodes in the AST.
}
public str fqPackageName(package(str name)) = name;
public str fqPackageName(package(Declaration parent, str name)) = "<fqPackageName(parent)>.<name>";


private Color determineGreenToRed(int nr){
	//credit for example goes to: http://stackoverflow.com/questions/340209/generate-colors-between-red-and-green-for-a-power-meter
	return rgb( toInt((100*nr)/5) , toInt((255*(80-nr))/100), 0);
}

@DOC{
This function determines the color for a given cyclomatic complexity.
The colors generated start from 1 for green to 50 for red and orange-ish for in between.
CC above 50 remains red.

pram: 1 or higher
}
public Color determineComplexityColor(int cc) =	determineGreenToRed(cc);


@DOC{
 Creates a few visual boxes to see the CC colors.
}
public void testColorForCC(){
	render( hcat( [ box(fillColor( determineComplexityColor(i) )) | i <- [1..50] ] ) );
}

@DOC{
2 or more
The colors generated start from 2 to 5

pram: 2 or higher which represents the number of classes that share a certain clone}
public Color duplicationColor(int nr){
	return determineGreenToRed(nr*10-10);
}

@DOC{
 Creates a few visual boxes to see the CC colors.
}
public void testColorForDuplication(){
	render( hcat( [ box(fillColor( duplicationColor(i) )) | i <- [1..6] ] ) );
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
