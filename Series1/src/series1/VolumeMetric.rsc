module series1::VolumeMetric

import IO;
import String;
import lang::java::m3::AST;

import series1::utils;

public int sloc(set[Declaration] ast, set[str] comments){
	int lines = 0;
    for(/c:compilationUnit(package, _, _) <- ast){
    	lines += sloc(c@src, comments);
    }
    return lines;
}

public lrel[int, str, loc] slocPerUnit(set[Declaration] ast, set[str] comments){
    return for(/compilationUnit(package, _, /class(className, _,_, /m:method(_, name, _, _, s) )) <- ast)
        append <sloc(s@src, comments), "<fqPackageName(package)>.<className>#<name>", m@src>;
}

private int sloc(loc code, set[str] comments){
	int count = 0;
	list[str] lines = readFileLines(code);
	for(line <- lines){
		line = trim(line);
		if(size(line)>0 && line notin comments){
			count += 1;
		}
	}
	return count;
}