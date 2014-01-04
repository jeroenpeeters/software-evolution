module series1::DuplicationMetric

import IO;
import List;
import Set;
import String;
import util::Math;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import util::Benchmark;
import Map;

import Utils;

private	map[value, int] benchmark=();

private void addToBenchmark(value key, int val){
	if(key in benchmark){
		int oldVal = benchmark[key];
		benchmark[key] = oldVal+ val;
	} else {
		benchmark[key] = val;
	}
}

private void printBenchmark(){	
	for(mark <- benchmark){
		println("<benchmark[mark]> ms for <mark>");
	}
}

@DOC{

This function returns a map which contains clones related to their associated files.
Each list is at equal or larger than the given block size.

Performance warnings:
Since the list <= list function of Rascal is broken, a new function inSameOrder is written in Utils.
Since this function is used alot, it might be a bottle neck. However, this function is optimized as possible.

So, how does this algorithm works?
1. It creates a map containing unit(loc) to their useful lines like: SomeClass.java -> [its list of lines]
2. it iterates over each unit doing the following:
	a. take a block as given size from the start of the unit
	b. iterate over all other units 
	c. if the existing block is found in any other unit, it means there is a clone, 
	d. increment the same block with one more line, to make sure the while cloned part is covered.
	e. continue checking and incrementing until no extra match is found or either of the units are ended
	f. move the next block index point to the right place
	g. save the cloned block and its unit references
	h. continue to next unit
3. It adds the found block which is at least as big as the given blocksize to the list of clones
4. While adding the new found clone, it preserves any previous unit if for the same clone anything is already found.
5. Finally, a map of clones to their associated locations are baked and returned.
}
public map[list[str], set[loc] ] findFilteredClones(set[Declaration] ast, blockSize, set[str] comments){
	int startTime = getMilliTime();

	map[loc, list[str] ] unitToLines = mapUnitsTolines(ast, comments);

	addToBenchmark("unitToLines", getMilliTime() - startTime);
	
	set[loc] checkedUnits ={};
	map[list[str], set[loc] ] clones = ();
	
    for(unit <- unitToLines){
    	checkedUnits+=unit;
    	
    	int unitStart = getMilliTime();
    	
    	list[str] unitLines = unitToLines[unit];
    	int nrOfLines = size(unitLines);
    	
    	int presentIndex = 0;

    	while(presentIndex+blockSize < nrOfLines) {
   		
    		list[str] presentBlock = slice(unitLines, presentIndex, blockSize);
    		
    		 for(otherUnit <- unitToLines){
    		 
    		 	if(otherUnit != unit && otherUnit notin checkedUnits ){
    		 		list[str] otherUnitLines = unitToLines[otherUnit];
    		 		
    		 		int orderStart = getMilliTime();
    		 		
    		 		if(inSameOrder(presentBlock, otherUnitLines)){
    		 			int foundStart = getMilliTime();
    		 			println("We found a clone <presentBlock> in otherUnit <otherUnitLines>");
    		 			
    		 			int tempBlockSize = blockSize+1;
    		 			bool noMore = false;
    		 			while(!noMore && presentIndex+tempBlockSize < nrOfLines) {    		 		
    		 				newBlock = slice(unitLines, presentIndex, tempBlockSize);    		 			
    		 				
    		 				if(inSameOrder(newBlock, otherUnitLines)) {
    		 					presentBlock = newBlock;
    		 					tempBlockSize+=1;
    		 				} else {
    		 					noMore=true;
    		 				}		
    		 			}
    		 				 			
    		 			if( presentBlock in clones ) {
    		 				previosUnits = clones[presentBlock];
    		 				clones[presentBlock] = previosUnits+={unit,otherUnit};
    		 			} else {
    		 				clones[presentBlock] = {unit,otherUnit};
    		 			}
    		 			presentIndex = presentIndex+tempBlockSize - blockSize;
    		 			
    		 			addToBenchmark("foundAndIncrementing", getMilliTime()-foundStart);
    		 		}	
    		 		addToBenchmark("inSameOrderTotal", getMilliTime()-orderStart);
    		 	}
    		 } 
    		presentIndex+=1;
    	}
    	
	    addToBenchmark("block", getMilliTime() - unitStart);
    }
    
	addToBenchmark("total", getMilliTime() - startTime);
	printBenchmark();
	return clones;
}

//test Data
public map[loc, list[str]] map1 = (|project://SimpleJava/|:["a","b"],  
									|project://SimpleJava4/|:["a","d"],  
									|project://SimpleJava3/|:["a","d"],  
									|project://SimpleJava2/|:["c","d"]);
//This method returns a set of locations that definitly has clones. 
//However, the calculation is done purely based on the minimum blockSize, the clone size can be bigger
public set[loc] getLocationsWithClone(map[loc, list[str] ] locationToLines, int blockSize){
	map[list[str], set[loc]] blocksToLocs = ();
	set[loc] locationsWithClone = {};
	
	//each location has certain amount of lines
	for(location <- locationToLines) {
		
		list[str] locationLines = locationToLines[location];
		int nrOfLines = size(locationLines);
		
		//we create blocks of lines according to given blockSize for 
		//[1,2,3] with blockSize 2 will produce [[1,2],[2,3],[3,4]
		list[list[str]] blocks = [slice(locationLines,s,e) | s <- [0..nrOfLines], e <- [blockSize..blockSize+1], s+e <= nrOfLines];
		
		//each block is used as a key and its values are the locations. If for any block, more locations are found, that block has clones.
		for(block <- blocks){
			// if any block already has a location, now this is a clone
			if(block in blocksToLocs){
				previousLocs = blocksToLocs[block];
				blocksToLocs[block] = previousLocs+=location;
				// we add both
				locationsWithClone+=previousLocs;
				locationsWithClone+=location;
			} else {
				blocksToLocs[block] = {location};
			}
		}
	}
	return locationsWithClone;
}

private map[list[str], set[loc]] allBlocksToAllLocs = ();

private void addBlocksToLoc(list[str] unitLines, loc location, int blockSize){
	int addBlockStart = getMilliTime();
	
	int nrOfLines = size(unitLines);
	list[list[str]] blocks = [slice(unitLines,s,e) | s <- [0..nrOfLines], e <- [blockSize..nrOfLines+1], s+e <= nrOfLines];
	
	for(block <- blocks){
		
		bool handled = false;
		
		for(blockToLoc <- allBlocksToAllLocs) { 
			if(blockToLoc < block ){
				set[loc] locations = allBlocksToAllLocs[blockToLoc];
				locations+=location;
				
				delete(allBlocksToAllLocs,blockToLoc);
				
				allBlocksToAllLocs[block] = locations;
				handled = true;
				
			} else if(block < blockToLoc || block == blockToLoc){
				set[loc] locations = allBlocksToAllLocs[blockToLoc];
				locations+=location;
				allBlocksToAllLocs[blockToLoc] = locations;
				handled=true;
			} 
		}
		
		if(!handled){
			allBlocksToAllLocs[block] = {location};
		}
	}
	addToBenchmark("addBlocksToLoc", getMilliTime() - addBlockStart);
}

private map[list[str], set[loc]]  getUnitsWithDuplication() {
	map[list[str], set[loc]] unitsWithDuplication =();
	
	for(block <- allBlocksToAllLocs){
	
		if(size( allBlocksToAllLocs[block] ) > 1 ){
			unitsWithDuplication[block] = allBlocksToAllLocs[block];
		}
	}	
	return unitsWithDuplication;
}

private void resetMaps() {
	allBlocksToAllLocs = ();
	benchmark=();
}

public map[list[str], set[loc] ] findClonesByMap(set[Declaration] ast, blockSize, set[str] comments){
	resetMaps();
	int startTime = getMilliTime();

	map[loc, list[str] ] unitToLines = mapUnitsTolines(ast, comments);

	addToBenchmark("unitToLines", getMilliTime() - startTime);
	
	set[loc] locationsWithClone = getLocationsWithClone(unitToLines, blockSize);
	
	println("cloned locs\n<locationsWithClone>");
	
	int slicingStart = getMilliTime();
	
	for(unit <- unitToLines) {   
		if(unit in locationsWithClone) {
			println("unit in clone \n<unit>");
		    list[str] unitLines = unitToLines[unit];  	
			addBlocksToLoc(unitLines, unit, blockSize);
		}
	}

	addToBenchmark("SlicingAndAdding", getMilliTime() - slicingStart);

	map[list[str], set[loc]] unitsWithClone = getUnitsWithDuplication();

	printBenchmark();
	
	return unitsWithClone;
}


@DOC{
This function produces a map of given locations to their useful lines.
}
private map[loc, list[str] ] mapUnitsTolines(set[Declaration] ast, set[str] comments){	
	map[loc, list[str] ] unitToLines =();
	
    for(/c:compilationUnit( package, imports, types) <- ast){   	
    	unitLines =[];
    	for(line <- readFileLines(c@src)){   	
			tLine=trim(line);
		
			if(size(tLine) > 0 && !startsWith(tLine, "import") && tLine notin comments && line notin comments){
				unitLines+=tLine;
			}					
    	}	
    	unitToLines[c@src] = unitLines;   	
    }
    
    return unitToLines;
}



//Deprecated
public data Line = Line(str);
private anno int Line @ nr;

public Line makeLine(str code, int lineNum){
	l = Line(code, lineNum);
	l@nr = lineNum;
	return l;
}

//Deprecated: Use findFilteredClones
//the comments can be read by Utils
public real duplication(set[Declaration] ast, set[str] comments) = duplication(ast, 6, comments);

//Deprecated: Use findFilteredClones
public real duplication(set[Declaration] ast, blocksize, set[str] comments){
	set[list[Line]] blocks = {};
	
	map[Declaration, list[Line] ] classToLine =();
	
	int lineCount = 0;
    for(/c:compilationUnit(package, _, _) <- ast){

    	int lineNum = 0;
    	cunitLines = [];
    	list[str] lines = readFileLines(c@src);
		for(line <- lines){
			line = trim(line);
			if(line notin comments && size(line)>0){
				lineNum += 1;
				cunitLines += makeLine(line, lineNum);
			}
		}
    	
    	blocks += cunitLines;

    	classToLine+= (c: cunitLines);
    	lineCount += lineNum;
    }
    
    // make codeblocks of 6  or more lines
	set[list[Line]] codeBlocks = {};
	list[Line] duplist = [];
	
	map[list[Line], set[Declaration] ] clones = ();
    	
    for(classUnit <- classToLine){
    	lines = classToLine[classUnit];
    	len = size(lines)+1;
    	//a =  [slice(lines,s,e) | s <- [0..len], e <- [blocksize..blocksize+1], s+e < len];
    	list[list[Line]]  a =  [slice(lines,s,blocksize) | s <- [0..len], s+blocksize < len];
    	for(x <- a){
    	
			if(x in clones){
				set[Declaration] previosUnits = clones[x];
				clones[x] = previosUnits+=classUnit;
			} else {
				clones[x] = {classUnit};
			}
    		if( x in codeBlocks ){
    			duplist += x;
    		}else{
    			codeBlocks += x;
    		}
    	}
    }
    
    set[tuple[str, int]] duplicates = {};
    
	for(l:Line(code) <- duplist) {
		// reduce the duplicate set to unique lines
		duplicates += <code, l@nr>;
	}	
    return (toReal(size(duplicates))/lineCount)*100;
}