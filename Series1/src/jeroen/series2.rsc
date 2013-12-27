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

private data Class = Class(loc class);
private data Unit = Unit( loc method);
private anno int Unit @ cc;
private anno int Unit @ volume;

public void main(loc project){
	ast = createAstsFromEclipseProject(project, false);
	render(unitVolumeCCViz(ast, readComments(project)));
}

public Figure unitVolumeCCViz(ast, comments){
	a = [];
	//lrel[int, str, loc] slocList = reverse(sort(slocPerUnit(ast	, comments)));
	//map[str, tuple[int, loc]] complexityRels = ccPerUnit(ast);
	//real largest = toReal(slocList[0][0]);
	real largest = 10.0;
	map[Class, list[Unit]] classUnitMap = composedMetric(ast, comments);
	for(class:Class(loc classLoc) <- classUnitMap){
		blocks = [];
		for(u:Unit(loc methodLoc) <- classUnitMap[class]){
			println("<classLoc> :: <methodLoc> -\> <u@volume>");
			itemSize = (u@volume/largest) * 100;
			complexity = u@cc;
			c = false;
			blocks += box(area(itemSize), fillColor(determineComplexityColor(complexity)),
				onMouseDown(openLocation(methodLoc)), onMouseEnter(void () { c = true; }), onMouseExit(void () { c = false ; }));
		}
		a += treemap(blocks, std(gap(5)));
	}
	/*blocks += box(area(itemSize), fillColor(getColor(complexity)),
		//lineWidth(num () { return c ? 2 : 1; }),
		//lineColor(Color () { return c ? color("red") : color("black"); }),
		onMouseDown(open(ref)), onMouseEnter(void () { c = true; }), onMouseExit(void () { c = false ; }));
		*/
	return vcat(a);
}

public map[Class, list[Unit]] composedMetric(set[Declaration] ast, set[str] comments){
	map[Class, list[Unit]] classUnitMap = ();
    for(/compilationUnit(package, _, /c:class(className, _,_, /m:method(_, name, _, _, s) )) <- ast){
    	Class clazz = Class(c@src);
    	Unit u = Unit(m@src);
    	u@cc = cc(s, false);
    	u@volume = sloc(s@src, comments);
    	if(clazz notin classUnitMap){
    		classUnitMap[clazz] = [];
    	}
    	classUnitMap[clazz] += [u];
    }
    return classUnitMap;
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