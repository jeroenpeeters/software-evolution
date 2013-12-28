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

@DOC{
For better performance use inSameOrder(list,list)
returns true if the first list is present in the same order in the second list
}
public bool inSameOrder2(list[value] list1, list[value] list2){
	
	for(i <- [0..size(list2)] && i+size(list1) <= size(list2)){
		
		if(list1 == slice(list2, i, size(list1)) ){
			return true;
		}
		
	}
	return false;
}

@DOC{ 
inSameOrder2(list,list) could also be used, but this function performs better.
This function is written because the sublist function of Rascal (list1<=list2) has a bug.
Returns true if the first list is a sublist of the second list, preserving their order.
}
public bool inSameOrder(list[value] list1, list[value] list2){
	int size1 = size(list1);
	int size2 = size(list2);	
	
	if(size1 < 1 ){
		return true;
	}
	
	if(size2 < 1 || size2 < size1) {
		return false;
	}
	
	for(int i <- [0..size2] && (size2 - i) >= size1 ){
		
		bool found = false;
		for(ii <- [0..size1] && (size2 - i) >= size1){
		    
		    if(list1[ii] != list2[i+ii]) {
		    	found = false;
		    	break;
		    } else {   
		    	found = true;
		    }   
		}
		if(found){
			return true;
		}
	}
	return false;
}
