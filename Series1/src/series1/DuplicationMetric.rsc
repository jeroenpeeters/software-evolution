module series1::DuplicationMetric

import IO;
import List;
import Set;
import util::Math;
import lang::java::m3::AST;

private data Line = Line(str);
private anno int Line @ nr;

private Line makeLine(str code, int lineNum){
	l = Line(code);
	l@nr = lineNum;
	return l;
}

public real duplication(set[Declaration] ast) = duplication(ast, 6, 6);

public real duplication(set[Declaration] ast, minBlockSize, maxBlockSize){
	set[list[Line]] blocks = {};
	int lineCount = 0;
    for(/c:compilationUnit(package, _, _) <- ast){
    	str code = readFile(c@src);
    	int lineNum = 0;
    	cunitLines = [];
    	for(/<line:.*>[\n|\r|\t]+<rest:[.|\n|\r|\t]*>/ := code){
    		code = rest; // reduce code with rest
    		lineNum += 1;
    		cunitLines += makeLine(line, lineNum);
    	}
    	blocks += cunitLines;
    	lineCount += lineNum;
    }
    // make codeblocks of 6  or more lines
	set[list[Line]] codeBlocks = {};
	list[Line] duplist = [];
    for(lines <- blocks){
    	len = size(lines)+1;
    	a =  [slice(lines,s,e) | s <- [0..len], e <- [minBlockSize..maxBlockSize+1], s+e < len];
    	for(x <- a){
    		if( x in codeBlocks ){
    			duplist += x;
    		}else{
    			codeBlocks += x;
    		}
    	}
    }
    
    set[tuple[str, int]] duplicates = {};
	for(l:Line(code) <- duplist){
		// reduce the duplicate set to unique lines
		duplicates += <code, l@nr>;
	}
	
    return (toReal(size(duplicates))/lineCount)*100;
}