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

private data Line = Line(str);
private anno int Line @ nr;

public Line makeLine(str code, int lineNum){
	l = Line(code);
	l@nr = lineNum;
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
