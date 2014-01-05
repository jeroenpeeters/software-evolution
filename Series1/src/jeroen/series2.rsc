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
private anno list[Unit]  Class @ units;

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
	
	set[Class] classSet = composedMetric(ast, comments);
	for(class:Class(loc classLoc) <- classSet){
		list[Figure] blocks = []; 
		int classSize = 0;
		for(u:Unit(loc methodLoc) <- sort(class@units, unitsort)){
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
	
	set[Class] classSet = composedMetric(ast, comments);
	list[Unit] allUnits = [];
	for(class:Class(loc classLoc) <- classSet){
		allUnits += class@units;
	}
	
	allUnits = sort(allUnits, unitsort);
	for(u:Unit(loc methodLoc) <- allUnits){
		itemSize = u@volume;
		totalSize += itemSize;
		complexity = u@cc;
		
		figures += box(area(itemSize), fillColor(determineComplexityColor(complexity)), lineColor(color("grey")), lineWidth(1),
			onMouseDown(openLocation(methodLoc)), onMouseEnter(void () { c = true; }), onMouseExit(void () { c = false ; }));
	}
	return vscrollable(treemap(figures), height(totalSize/10), lineWidth(0));
}


public bool (Unit, Unit) unitsort = bool (Unit a, Unit b) {
	return a@cc > b@cc;
};

public int totalVolume(list[Unit] units) = sum([ u@volume | u <- units]);

public set[Class] composedMetric(set[Declaration] ast, set[str] comments){
	set[Class] classSet = {};
    for(/compilationUnit(package, _, /c:class(className, _,_, list[Declaration] body)) <- ast){
    	
    	Class clazz = Class(c@src);
    	clazz@units = [];
    	
    	for(/m:method(_, name, _, _, s) <- body){
    		Unit u = Unit(m@src);
    		u@cc = cc(s, false);
    		u@volume = sloc(s@src, comments);
    		clazz@units += u;
    	}

    	classSet += clazz;
    }
    return classSet;
}
