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

public void main(loc project, bool showClasses){
	ast = createAstsFromEclipseProject(project, false);
	render(unitVolumeCCViz(ast, readComments(project), showClasses));
}

public Figure unitVolumeCCViz(ast, comments, bool showClasses){
	if(!showClasses){
		return unitVolumeCCVizNoClasses(ast, comments);
	}
	list[Figure] figures = []; // list of figures to be rendered into the treemap
	int totalSize = 0; // total size of the project
	
	map[Class, list[Unit]] classUnitMap = composedMetric(ast, comments);
	for(class:Class(loc classLoc) <- classUnitMap){
		list[Figure] blocks = []; 
		int classSize = 0;
		for(u:Unit(loc methodLoc) <- sort(classUnitMap[class], sortUnits)){
			itemSize = u@volume;
			complexity = u@cc;
			c = false;
			
			blocks += box(area(itemSize), fillColor(determineComplexityColor(complexity)), lineColor(color("grey")), lineWidth(1),
				onMouseDown(openLocation(methodLoc)), onMouseEnter(void () { c = true; }), onMouseExit(void () { c = false ; }));
			classSize += itemSize;
		}
		totalSize += classSize;
		if(showClasses){
			figures += box( treemap(blocks), area(classSize), lineColor(color("black")), lineWidth(3));
		}else{
			figures = figures + blocks;
		}
	}
	/*blocks += box(area(itemSize), fillColor(getColor(complexity)),
		//lineWidth(num () { return c ? 2 : 1; }),
		//lineColor(Color () { return c ? color("red") : color("black"); }),
		onMouseDown(open(ref)), onMouseEnter(void () { c = true; }), onMouseExit(void () { c = false ; }));
		*/
	return vscrollable(treemap(figures), height(totalSize/10), lineWidth(0));
}

public Figure unitVolumeCCVizNoClasses(ast, comments){
	list[Figure] figures = []; // list of figures to be rendered into the treemap
	int totalSize = 0; // total size of the project
	
	map[Class, list[Unit]] classUnitMap = composedMetric(ast, comments);
	list[Unit] allUnits = [];
	for(class:Class(loc classLoc) <- classUnitMap){
		allUnits += classUnitMap[class];
	}
	
	allUnits = sort(allUnits, sortUnits);
	for(u:Unit(loc methodLoc) <- allUnits){
		itemSize = u@volume;
		totalSize += itemSize;
		complexity = u@cc;
		
		figures += box(area(itemSize), fillColor(determineComplexityColor(complexity)), lineColor(color("grey")), lineWidth(1),
			onMouseDown(openLocation(methodLoc)), onMouseEnter(void () { c = true; }), onMouseExit(void () { c = false ; }));
	}
	return vscrollable(treemap(figures), height(totalSize/10), lineWidth(0));
}


public bool (Unit, Unit) sortUnits = bool (Unit a, Unit b) {
	return a@cc > b@cc;
};

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
