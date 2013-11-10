module yosuf::SigMM

extend yosuf::Volume;


import lang::java::jdt::m3::AST;
import IO;
import List;

/*For Ranking*/
import jeroen::metrics;

//eclipse project locations
public loc simple	 = |project://SimpleJava/|;
public loc simpleInterface	 = |project://SimpleJava/src/very/SimpleInterface.java/|;
public loc printer	 = |project://SimpleJava/src/very/simple/Printer.java/|;
public loc simpleClass	 = |project://SimpleJava/src/very/simple/SimpleClass.java/|;

public loc smallSql	 = |project://SmallSQL/|;
public loc hsql	 = |project://hsql/|;

public loc scrumviz	 = |project://scrumviz/|;


public void calculateVolumeForProject(loc projectName){
   set[Declaration] projectAst = createAstsFromEclipseProject(projectName,false);
 
   num count = sum( [  cacluateSLOC(decl)  | decl <-projectAst] );
 
   println("Total project SLOC: <count>");
}

public void calculateVolumeForFile(loc fileName){
   Declaration decl = createAstsFromEclipseFile(fileName,false);
   
   int count = cacluateSLOC(decl);
 
   println("Total File SLOC: <count>");
}


/**Duplicaton Warning! extend yosuf::Volume does not work... Why?*/

	bool printEnabled = false;

//http://tutor.rascal-mpl.org/Rascal/Rascal.html#/Rascal/Libraries/lang/java/m3/AST/Declaration/Declaration.html
public int cacluateSLOC(Declaration ast){
    int count = 0;
    visit(ast){    
     	   
     	   /*We count all the Declarations except the following*/
     	   case package(p1,p2)       	     :print("skipped pack <package(p1,p2) >"); //is included in package with one arg
     	   case variables(p1,p2)          :print("skipped variables <variables(p1,p2) >");
    	    case parameter(p1,p2,p3)       :print("skipped param <parameter(p1,p2,p3) >");
     	   case compilationUnit(p1,p2)    :print("skipped compunit <compilationUnit(p1,p2)>" );
     	   case compilationUnit(p1,p2,p3) :print("skipped compunit <compilationUnit(p1,p2,p3)>" );
      	  /**/
     	   case Declaration d             :{count+=1; print("d: <d>"); }
     	   
     	   /*Statements skipped*/
     	   case block(_) :;
     	   case Statement s              :{count+=1; print("s: <s>"); }
     	   
     	   // One or the other way, else block is skipped...
     	   //Annotations?
    }
    return count;
}


/**
* Originally from Jeroens idea where node is printed.
*/
public void print(str arg){
	 if(printEnabled){
	   println(arg);
	 }
	}
