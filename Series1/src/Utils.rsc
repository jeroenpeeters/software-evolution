module Utils

import lang::java::m3::AST;
import vis::Figure;
import vis::Render;
import util::Math;

import vis::KeySym;
import util::Editors;

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