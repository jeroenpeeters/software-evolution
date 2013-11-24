module series1::VolumeMetric

import IO;
import String;
import lang::java::m3::AST;

import series1::utils;

public int sloc(set[Declaration] ast){
	int lines = 0;
    for(/c:compilationUnit(package, _, _) <- ast){
    	lines += sloc(c@src);
    }
    return lines;
}

public lrel[int, str, loc] slocPerUnit(set[Declaration] ast){
    return for(/compilationUnit(package, _, /class(className, _,_, /m:method(_, name, _, _, s) )) <- ast)
        append <sloc(s@src), "<fqPackageName(package)>.<className>#<name>", m@src>;
}


private int sloc(loc code){
	int count = 0;
	list[str] lines = readFileLines(code);
	for(line <- lines){
		line = trim(line);
		switch(line){
			case /^$/: ; 		// exclude empty lines
			case /^\/\/.*$/: ; 	// exlude comment from line count (// ...)
			case /^\/\*.*$/: ; 	// exlude comment from line count (/* or /**)
			case /^\*.*$/: ; 	// exlude comment from line count (*)
			case /^[{|}].*$/: ; // exclude { or } on single line
			default: count +=1;
		}
	}
	return count;
}