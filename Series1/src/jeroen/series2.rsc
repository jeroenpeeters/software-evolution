module jeroen::series2

import IO;
import List;
import Set;
import String;
import util::Math;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import vis::Figure;
import vis::Render;
import vis::KeySym;

import util::Editors;

import series1::CCMetric;
import series1::VolumeMetric;
import Utils;

public loc smallsql     = |project://smallsql0.21_src/|; //bechnmark: 18seconds
public loc hsqldb       = |project://hsqldb-2.3.1/|; // benchmark: 2min32sec
public loc simplejava   = |project://SimpleJava/|; // benchmark: <1sec

private data Unit = Unit(loc);
private anno int Unit @ cc;
private anno int Unit @ volume;

public void main(loc project){
	ast = createAstsFromEclipseProject(project, false);
	render(unitVolumeCCViz(ast, readComments(project)));
}

public Figure unitVolumeCCViz(ast, comments){
	blocks = [];
	//lrel[int, str, loc] slocList = reverse(sort(slocPerUnit(ast	, comments)));
	//map[str, tuple[int, loc]] complexityRels = ccPerUnit(ast);
	//real largest = toReal(slocList[0][0]);
	real largest = 10.0;
	list[Unit] unitList = composedMetric(ast, comments);
	for(Unit u <- unitList){
		itemSize = (u@volume/largest) * 100;
		complexity = u@cc;
		blocks += box(area(itemSize), fillColor(getColor(complexity)));
	}
	/*for(<size, name, ref> <- slocList){
		itemSize = (size/largest) * 100;
		tuple[int cc, loc r] info = complexityRels[name];
		int complexity = info.cc;
		c = false;
		blocks += box(area(itemSize), fillColor(getColor(complexity)),
			//lineWidth(num () { return c ? 2 : 1; }),
			//lineColor(Color () { return c ? color("red") : color("black"); }),
			onMouseDown(open(ref)), onMouseEnter(void () { c = true; }), onMouseExit(void () { c = false ; }));
	}*/
	return treemap(blocks, std(gap(5)));
}

public list[Unit] composedMetric(set[Declaration] ast, set[str] comments){
	list[Unit] unitList = [];
    for(/compilationUnit(package, _, /class(className, _,_, /m:method(_, name, _, _, s) )) <- ast){
    	Unit u = Unit(m@src);
    	u@cc = cc(s, false);
    	u@volume = sloc(s@src, comments);
    	unitList += u;
    }
    return unitList;
}

private str getColor(int cc) {
	if(cc < 0){
		return "black";
	} else if(cc < 5){
		return "lime";
	} else if(cc < 10){
		return "limegreen";
	} else if (cc < 20){
		return "yellow";
	} else if (cc < 40){
		return "tomato";
	} else if(cc < 50){
		return "red";
	} else {
		return "darkred";
	}
}