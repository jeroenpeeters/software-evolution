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

import series1::VolumeMetric;

public loc smallsql     = |project://smallsql0.21_src/|; //bechnmark: 18seconds
public loc hsqldb       = |project://hsqldb-2.3.1/|; // benchmark: 2min32sec
public loc simplejava   = |project://SimpleJava/|; // benchmark: <1sec

public void main(loc project){
	M3 m3 = createM3FromEclipseProject(project);
	
	comments = {};
	for(<_,l> <- m3@documentation){
		comments += toSet(readFileLines(l));
	}
	
	ast = createAstsFromEclipseProject(project, false);

	render(unitVolumeViz(ast, comments));
}

public Figure unitVolumeViz(ast, comments){
	blocks = [];
	lrel[int, str, loc] slocList = reverse(sort(slocPerUnit(ast	, comments)));
	real largest = toReal(slocList[0][0]);
	for(<size, name, ref> <- slocList){
		itemSize = (size/largest) * 100;
		short = substring(name, 1+findLast(name, "."));
		c = false;
		blocks += box(text("<size>", fontSize(toInt(itemSize/8))), area(itemSize), fillColor(arbColor()),
			lineWidth(num () { return c ? 2 : 1; }),
			lineColor(Color () { return c ? color("red") : color("black"); }),
			onMouseDown(openLocation(ref)), onMouseEnter(void () { c = true; }), onMouseExit(void () { c = false ; }));
	}
	return treemap(blocks, std(gap(5)));
}

