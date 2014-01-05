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

private data Class = Class(loc class, str className, str package);
private anno list[Unit]  Class @ units;

private data Unit = Unit(loc method, str name);
private anno int Unit @ cc;
private anno int Unit @ volume;

public void main(loc project, bool showClasses){
	ast = createAstsFromEclipseProject(project, false);
	render("UnitVolumeCC Vis", unitVolumeCCViz(ast, readComments(project), showClasses));
}

public Figure unitVolumeCCViz(ast, comments, bool showClasses){
	if(!showClasses){
		return unitVolumeCCVizNoClasses(ast, comments);
	}
	list[Figure] figures = []; // list of figures to be rendered into the treemap
	num totalSize = 0; // total size of the project
	
	c = false;
	str selClass = "";
	str selMethod = "";
	str selSize = "";
	str selCC = "";
	row1 = [
		box(text( str () {return selClass;}, left(), fontSize(10)), hshrink(0.5), lineWidth(0)), 
		text("Volume LOC", fontSize(10), fontBold(true), left()), 
		text( str () {return selSize;}, left(), fontSize(10), left())];
	row2 = [
		box(text( str () {return selMethod;}, left(),fontSize(12), fontBold(true)), hshrink(0.5), lineWidth(0)), 
		text("Cyclomatic complexity", fontSize(10), fontBold(true), left()),
		text( str () {return selCC;}, left(), fontSize(10), left())];
		
	infoBox = grid([row1,row2], hgap(10), fillColor("white"), vshrink(0.1));
	
	set[Class] classSet = composedMetric(ast, comments);
	for(class:Class(loc classLoc, str className, str package) <- classSet){
		list[Figure] blocks = []; 
		num classSize = sum([u@volume | u <- class@units]);
		//println(className);
		//println(classSize);
		setPrecision(10);
		real x = 0.0;
		for(u:Unit(loc methodLoc, str unitName) <- sort(class@units, unitsort)){
			itemSize = toReal(u@volume);
			complexity = u@cc;
			mpackage = "<package>.<className>";
			mname = unitName;
			
			//println(unitName);
			//println(itemSize);
			//println(itemSize/classSize);
			
			/*real diff = 0.0;
			if(x+ (itemSize/classSize) > 1.0)diff = 1-x;
			
			x += (itemSize/classSize) - diff;
			//println(x);
			
			if(diff != 0){
				println(unitName);
				println("d:<diff>");
				println(x);
			}*/
			
			//hshrink((((itemSize)/classSize)-diff))
			
			blocks += box(fillColor(determineComplexityColor(complexity)), lineColor(color("grey")), lineWidth(1),
				onMouseDown(openLocation(methodLoc)), onMouseEnter(void () {c=true; selMethod=mname; selClass=mpackage;selSize="<itemSize>";selCC="<complexity>";}), onMouseExit(void () { c = false ; }));
		}
		totalSize += classSize;
		if(showClasses){
			figures += box( hcat(blocks), area(classSize), lineColor(color("black")), lineWidth(3));
		}else{
			figures = figures + blocks;
		}
	}
	/*blocks += box(area(itemSize), fillColor(getColor(complexity)),
		//lineWidth(num () { return c ? 2 : 1; }),
		//lineColor(Color () { return c ? color("red") : color("black"); }),
		onMouseDown(open(ref)), onMouseEnter(void () { c = true; }), onMouseExit(void () { c = false ; }));
		*/
		
	
	return vcat([infoBox, vscrollable(treemap(figures, height(totalSize/10)), lineWidth(0)) ]);
	//return treemap(figures);
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
	//return treemap(figures);
}


public bool (Unit, Unit) unitsort = bool (Unit a, Unit b) {
	return a@cc > b@cc;
};

public int totalVolume(list[Unit] units) = sum([ u@volume | u <- units]);

public set[Class] composedMetric(set[Declaration] ast, set[str] comments){
	set[Class] classSet = {};
    for(/compilationUnit(package, _, /c:class(className, _,_, list[Declaration] body)) <- ast){
    	
    	Class clazz = Class(c@src, className, fqPackageName(package));
    	clazz@units = [];
    	
    	for(/m:method(_, name, _, _, s) <- body){
    		Unit u = Unit(m@src, name);
    		u@cc = cc(s, false);
    		u@volume = sloc(s@src, comments);
    		clazz@units += u;
    	}

    	classSet += clazz;
    }
    return classSet;
}
