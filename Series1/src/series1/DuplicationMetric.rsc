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
import Utils;

public data Line = Line(str, int);
private anno int Line @ nr;

public Line makeLine(str code, int lineNum){
	l = Line(code, lineNum);
	//l@nr = lineNum;
	return l;
}

//the comments can be read by Utils
public real duplication(set[Declaration] ast, set[str] comments) = duplication(ast, 6, comments);

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
    			
    			println("\nDuplicate found <x>");
    		
    	
    		
    			
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
	
	
	for(key <- clones){
		int valSize =  size( clones[key] );
		values = clones[key];
		println("\n\nkey= <key> \nsize= <valSize> \nValues= <values>\n\n");
	}
	
    return (toReal(size(duplicates))/lineCount)*100;
}



public map[list[Line], set[Declaration] ] findClones(set[Declaration] ast, blocksize, set[str] comments){
	set[list[Line]] blocks = {};
	
	map[Declaration, list[Line] ] classToLineMap =();
	
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

    	classToLineMap+= (c: cunitLines);
    	lineCount += lineNum;
    }
    
	set[list[Line]] codeBlocks = {};
	list[Line] duplist = [];
	
	map[list[Line], set[Declaration] ] clones = ();
    	
    for(classUnit <- classToLineMap){
    	lines = classToLineMap[classUnit];
    	len = size(lines)+1;
    	list[list[Line]]  a =  [slice(lines,s,blocksize) | s <- [0..len], s+blocksize < len];
    	
    	for(x <- a){
    	
			if(x in clones){
				set[Declaration] previosUnits = clones[x];
				clones[x] = previosUnits+=classUnit;
				
			} else {
				clones[x] = {classUnit};
			}
    	}
    }

	return clones;
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

public map[list[str], set[loc] ] findFilteredClones(set[Declaration] ast, blockSize, set[str] comments){
	map[loc, list[str] ] unitToLines = mapUnitsTolines(ast, comments);
	
	set[loc] checkedUnits ={};
	
	map[list[str], set[loc] ] clones = ();
	
    int cloneCount=0;
    for(unit <- unitToLines){
    	checkedUnits+=unit;
    	
    	list[str] unitLines = unitToLines[unit];
    	int nrOfLines = size(unitLines);
    	
    	int presentIndex = 0;

    	while(presentIndex+blockSize < nrOfLines) {
   		
    		list[str] presentBlock = slice(unitLines, presentIndex, blockSize);
    		
    		 for(otherUnit <- unitToLines){
    		 
    		 	if(otherUnit != unit && otherUnit notin checkedUnits ){
    		 
    		 		list[str] otherUnitLines = unitToLines[otherUnit];
    		 		
    		 		
    		 		if(inSameOrder2(presentBlock, otherUnitLines)){
    		 			println("We found a clone <presentBlock> in otherUnit <otherUnitLines>");
    		 			
    		 			int tempBlockSize = blockSize+1;	
    		 			
    		 			bool noMore = false;
    		 			while(!noMore && presentIndex+tempBlockSize < nrOfLines) {    		 		
    		 				newBlock = slice(unitLines, presentIndex, tempBlockSize);    		 			
    		 				
    		 				if(inSameOrder2(newBlock, otherUnitLines)) {
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
    		 			cloneCount+=1;
    		 		}
    		 		
    		 	}
    		 } 
    		
    		presentIndex+=1;
    	}
    }
    
    //println("\nClones count= <cloneCount>");
	return clones;
}

public void testIt() {
	loc project= |project://SimpleJava/|;
	M3 m3 = createM3FromEclipseProject(project);
	
	comments = {};
	for(<_,l> <- m3@documentation){
		comments += toSet(readFileLines(l));
	}

	ast = createAstsFromEclipseProject(project, false);
	clones=	findFilteredClones(ast, 6, comments);
	
	//for(clone <- clones) {
	//	println("\n<clone>");
	//}
}