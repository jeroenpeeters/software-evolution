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

//it uses a list of lines as key which potentially can be a clone and keeps a set of locations as values.
//if any value contains more locations, it means that there are multiple of the same list of lines throught the code (duplicaton). 
private map[list[str], set[loc]] allBlocksToAllLocs = ();
private	map[value, int] benchmark=();

private real clonePercentage;

private void addToBenchmark(value key, int val){
	if(key in benchmark){
		int oldVal = benchmark[key];
		benchmark[key] = oldVal+ val;
	} else {
		benchmark[key] = val;
	}
}

private void printBenchmark(){
	println("\nBenchmark information:");	
	for(mark <- benchmark){
		println("<benchmark[mark]> ms for <mark>");
	}
}

private void resetMaps() {
	allBlocksToAllLocs = ();
	benchmark=();
}

public real getClonePercentage() = clonePercentage;

//assumes that duplication is already calculated
private void caclulateClonePercentage(map[loc, list[str] ] unitToLines){
	int total = 0;
	for(location <- unitToLines) {
		total+= size( unitToLines[location] );
	}
	
	int clonesCount = 0;
	
	map[list[str], set[loc]] clones =  getUnitsWithDuplication();
	for(clone <- clones ){
		int cloneSize = size(clone);
		int relatedLocations = size( clones[clone] ) - 1;
		clonesCount+= (cloneSize * relatedLocations) ;
	}
	
	clonePercentage = (toReal(clonesCount) / toReal(total) ) * 100;
	
	println("totalLines: <total>, clone count: <clonesCount>, percentage <clonePercentage> % ");
}


public map[list[str], set[loc] ] findClonesByMap(set[Declaration] ast, blockSize, set[str] comments){
	resetMaps();
	int startTime = getMilliTime();

	map[loc, list[str] ] unitToLines = mapUnitsTolines(ast, comments);
	println("Done: mapping units to lines and removing comments.");
	addToBenchmark("unitToLines", getMilliTime() - startTime);
	
	set[loc] locationsWithClone = getLocationsWithClone(unitToLines, blockSize);
	println("Done: Finding units with clone.");
		
	int slicingStart = getMilliTime();

	for(unit <- unitToLines) {   
		if(unit in locationsWithClone) {
		    list[str] unitLines = unitToLines[unit];  	
			addBlocksForLoc(unitLines, unit, blockSize);
		}
	}
	println("Done: adding units to clones.");
	
	addToBenchmark("SlicingAndAdding", getMilliTime() - slicingStart);

	map[list[str], set[loc]] unitsWithClone = getUnitsWithDuplication();
	println("Done: filtering the cloned classes.");
	
	printBenchmark();
	
	caclulateClonePercentage(unitToLines);
	
	return unitsWithClone;
}
									
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

//this method slices, analyses and adds the given unit lines which corresponds to the given location
//to allBlocksToAllLocs
public map[list[str], set[loc]] addBlocksForLoc(list[str] unitLines, loc location, int blockSize){

	int addBlockStart = getMilliTime();
		
	int nrOfLines = size(unitLines);
	list[list[str]] blocks = [slice(unitLines,s,e) | s <- [0..nrOfLines], e <- [blockSize..nrOfLines+1], s+e <= nrOfLines];
	
	for(block <- blocks){
		
		bool handled = false;
		
		for(blockToLoc <- allBlocksToAllLocs) { 
			if(blockToLoc < block ){
				set[loc] locations = allBlocksToAllLocs[blockToLoc];
				locations+=location;
				
				allBlocksToAllLocs = delete(allBlocksToAllLocs, blockToLoc);
				
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
	addToBenchmark("addBlocksForLoc", getMilliTime() - addBlockStart);
	
	return allBlocksToAllLocs;
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

@DOC{
This function produces a map of given locations to their useful lines.
}
private map[loc, list[str] ] mapUnitsTolines(set[Declaration] ast, set[str] comments){	
	map[loc, list[str] ] unitToLines =();
	
    for(/c:compilationUnit( package, imports, types) <- ast){   	
    	unitLines =[];
    	for(line <- readFileLines(c@src)){   	
			tLine=trim(line);
		
			if(size(tLine) > 0 && !startsWith(tLine, "import") && !startsWith(tLine, "package") && tLine notin comments && line notin comments){
				unitLines+=tLine;
			}					
    	}	
    	unitToLines[c@src] = unitLines;   	
    }
    
    return unitToLines;
}

//test Data
public map[loc, list[str]] map1 = (|project://SimpleJava/|:["a","b"],  
									|project://SimpleJava4/|:["a","d"],  
									|project://SimpleJava3/|:["a","d"],  
									|project://SimpleJava2/|:["c","d"]);
