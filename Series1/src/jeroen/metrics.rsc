@contributor{Jeroen Peeters - jeroen@peetersweb.nl}
module jeroen::metrics

import IO;
import Node;
import List;
import Set;

import DateTime;

import util::Math;

import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;

public loc smallsql     = |project://smallsql0.21_src/|;
public loc hsqldb       = |project://hsqldb-2.3.1/|;
public loc simplejava   = |project://SimpleJava/|;

public set[Declaration] astH = createAstsFromEclipseProject(simplejava, false);
public set[Declaration] astS = createAstsFromEclipseProject(smallsql, false);
public set[Declaration] astS2 = createAstsFromEclipseProject(hsqldb, false);
public set[Declaration] sf = {createAstsFromEclipseFile(|project://SimpleJava/src/hello/world/Duplication.java|, false)};

data Rank = pp() | p() | n() | m() | mm();

@doc{
Computes metrics for the given Eclipse Project
}
public void computeMetricsForEclipseProject(loc project){
    ast = createAstsFromEclipseProject (project, false);
    
    println("LoC: <locMetric(ast)>
             'Rank Man Year Via Backfiring Function Points: <rankMyBackfiringFp(ast)>
             'Cyclomatic complexity: <cyclomaticComplexityPerUnit(ast)>");
}

@doc{
SIG Model; Volume; Lines of code
}
public int locMetric(set[Declaration] ast){
    int l = 0;
    visit(ast){
        /* Declarations */
        case parameter(_,_,_)   : ;
        case varargs(_,_)       : ;
        case package(_)         : ;
        case package(_,_)       : ;
        case Declaration d      : {l += 1; p(d);}
        
        /* Statements */
        case block(_)           : ;
        case Statement s        : {l += 1; p(s);}
    }
    return l;
}

@doc{
SIG Model; Volume; Man years via backfiring function points
}
public Rank rankMyBackfiringFp(set[Declaration] ast){
    kloc = locMetric(ast)/1000;
    if(kloc < 66){
        return pp();
    } else if(kloc >= 66 && kloc < 246){
        return p();
    } else if(kloc >= 246 && kloc < 665){
        return n();
    } else if(kloc >= 665 && kloc < 1310){
        return m();
    } else {
        return mm();
    }
    
}

@doc{
SIG Model; Complexity per unit
}
public lrel[int, str, loc] cyclomaticComplexityPerUnit(set[Declaration] ast){
    return for(/compilationUnit(package, _, /class(className, _,_, /m:method(_, name, _, _, s) )) <- ast)
        append <complexity(s), "<absolutePackageName(package)>.<className>#<name>", m@src>;
}

private int complexity(Statement stmnt){
    int i = 1;
    int retCount = -1;
    visit(stmnt){
    	case \return(): retCount += 1;
    	case \return(_): retCount += 1;
    	case \break(): i += 1;
    	case \break(_): i+= 1;
    	case \case(_): i += 1;
    	case \catch(_,_): i += 1;
    	case \continue(): i += 1;
    	case \continue(_): i+= 1;
    	case \do(_,_): i += 1;
    	case \foreach(_,_,_): i += 1;
    	case \for(_,_,_,_): i += 1;
    	case \for(_,_,_): i += 1;
    	case \if(Expression condition, Statement thenBranch, Statement elseBranch): i += 1;
    	case \if(Expression condition, Statement thenBranch): i += 1;
    	case \infix(_,"||",_,_): i += 1;
    	case \infix(_,"&&",_,_): i += 1;
    	case \throw(_): i += 1;
    	case \while(_,_): i += 1;
    	
    }
    retCount = retCount == -1 ? 0 : retCount;
    return i + retCount;
}

data Line = Line(str);
anno int Line @ nr;

private Line makeLine(str code, int lineNum){
	l = Line(code);
	l@nr = lineNum;
	return l;
}

public void duplication(set[Declaration] ast){
	list[Line] lines = [];
    for(/c:compilationUnit(package, _, _) <- ast){
    	str code = readFile(c@src);
    	int lineNum = 1;
    	for(/<line:.*>[\n|\r|\t]+<rest:[.\n\r\t]*>/ := code){
    		code = rest; // reduce code with rest
    		lines += makeLine(line, lineNum);
    		lineNum += 1;
    	}
    }
    
    // count duplicate matches
    // consolidate lines
    
    set[tuple[str, int]] duplicates = {};
    // compute duplicate sets with 6 lines or more
    for([*X,*A,*Y,*A,*Z] := lines, size(A)>5){
    	for(l:Line(code) <- A){
    		// reduce the duplicate set A to unique lines
    		duplicates += <code, l@nr>;
    	}
    }
    
    real duplicatePercentage = (toReal(size(duplicates))/size(lines))*100;
    println(size(lines));
    println(size(duplicates));
    println(duplicatePercentage);   
}

public void duplication2(set[Declaration] ast){
	t0 = now();
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
    println("a");
    // make codeblocks of 6  or more lines
	set[list[Line]] codeBlocks = {};
	list[Line] duplist = [];
    for(lines <- blocks){
    	len = size(lines)+1;
    	a =  [slice(lines,s,e) | s <- [0..len], e <- [6..10], s+e < len];
    	for(x <- a){
    		if( x in codeBlocks ){
    			duplist += x;
    		}else{
    			codeBlocks += x;
    		}
    	}
    }
    
    println("b");
    
    //diff = codeBlocks - dup(codeBlocks);
    
    println("c");
    
    set[tuple[str, int]] duplicates = {};
	//for(lines <- diff){
		for(l:Line(code) <- duplist){
			// reduce the duplicate set to unique lines
			duplicates += <code, l@nr>;
		}
	//}
	
	println("a");
	
	t1 = now();
	
	println(t1-t0);
	
    real duplicatePercentage = (toReal(size(duplicates))/lineCount)*100;
    println(lineCount);
    println(size(duplicates));
    println(duplicatePercentage);
}

public void duplication3(set[Declaration] ast){
	t0 = now();
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
    println("a");
    // make codeblocks of 6  or more lines
	set[list[Line]] codeBlocks = {};
	list[Line] duplist = [];
    for(lines <- blocks){
    	len = size(lines)+1;
    	a =  [slice(lines,s,e) | s <- [0..len], e <- [6..10], s+e < len];
    	for(x <- a){
    		if( x in codeBlocks ){
    			duplist += x;
    		}else{
    			codeBlocks += x;
    		}
    	}
    }
    
    println("b");
    
    //diff = codeBlocks - dup(codeBlocks);
    
    println("c");
    
    set[tuple[str, int]] duplicates = {};
	//for(lines <- diff){
		for(l:Line(code) <- duplist){
			// reduce the duplicate set to unique lines
			duplicates += <code, l@nr>;
		}
	//}
	
	println("a");
	
	t1 = now();
	
	println(t1-t0);
	
    real duplicatePercentage = (toReal(size(duplicates))/lineCount)*100;
    println(lineCount);
    println(size(duplicates));
    println(duplicatePercentage);
}


/**
 * Private section from here on
 */

private str absolutePackageName(package(str name)) = name;
private str absolutePackageName(package(Declaration parent, str name)) = "<absolutePackageName(parent)>.<name>";

@doc{
Prints a node, this method is used to centralize switching output on or off.
}
private void p(node n){
    //println(n); // comment-out to turn output off
}

