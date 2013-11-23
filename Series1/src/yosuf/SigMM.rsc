module yosuf::SigMM

extend yosuf::Volume;


import lang::java::jdt::m3::AST;
import IO;
import List;
import util::ValueUI;

/*For Ranking*/
import jeroen::metrics;

bool printEnabled = false;

//eclipse project locations
public loc simple	 = |project://SimpleJava/|;
public loc simpleInterface	 = |project://SimpleJava/src/very/SimpleInterface.java/|;
public loc printer	 = |project://SimpleJava/src/very/simple/Printer.java/|;
public loc simpleClass	 = |project://SimpleJava/src/very/simple/SimpleClass.java/|;
public loc complexity	 = |project://SimpleJava/src/very/simple/SimpleComplexity.java/|;

public loc smallSql	 = |project://SmallSQL/|;
public loc hsql	 = |project://hsql/|;

public loc scrumviz	 = |project://scrumviz/|;


public void calculateVolumeForProject(loc projectName){
   set[Declaration] projectAst = createAstsFromEclipseProject(projectName,false);
 
   num count = sum( [  cacluateSLOC(decl)  | decl <-projectAst] );
 
   println("Total project SLOC: <count>");
}

public void calculateVolumeForFile(loc fileName){
   Declaration ast = createAstsFromEclipseFile(fileName,false);
   
   int count = cacluateSLOC(ast);

   println("Total File SLOC: <count>");
}

//http://tutor.rascal-mpl.org/Rascal/Rascal.html#/Rascal/Libraries/lang/java/m3/AST/Declaration/Declaration.html
public int cacluateSLOC(Declaration ast){
    int count = 0;
    visit(ast){    
    		
    /**
    *TODO:
    * Else block is not counted
    * Annotations are not yet there
    */

           //case a:/annotation(_) : println("anno <a>");
     	   case x:/normalAnnotation(_,_) 	 : { println("markerAnnotation _,_ <x> ");}
     	   case mm:markerAnnotation(_)		 : { println("markerAnnotation _ <mm>  ");}
     	   case z:/annotation(_) 		     : { println("annotation _ <z> ");}
     	   case t:/annotationType(_,_)        : {println("annotationType: <t>");}
     	   case m:/annotationTypeMember(_,_)  : {println("annotationTypeMember: <m>");}
     	   case b:/annotationTypeMember(_,_,_)        : {println("annotationTypeM b: <b>");}
     	   case s:/singleMemberAnnotation(_,_): { println("singlemem <s>"); }
     	   
     	   /*We count all the Declarations except the following*/
     	   case package(p1,p2)       	  :print("skipped pack <package(p1,p2) >"); //is included in package with one arg
     	   case variables(p1,p2)          :print("skipped variables <variables(p1,p2) >");
    	   case parameter(p1,p2,p3)       :print("skipped param <parameter(p1,p2,p3) >");
     	   case compilationUnit(p1,p2)    :print("skipped compunit <compilationUnit(p1,p2)>" );
     	   case compilationUnit(p1,p2,p3) :print("skipped compunit <compilationUnit(p1,p2,p3)>" );
      	  
     	   case Declaration d             :{count+=1; print("d: <d>"); }
     	  	
     	  	 
     	   /*Statements skipped*/
     	   case b:block(_) : print("block <b>");
     	   
     	   case Statement s              :{count+=1; print("s: <s>"); }
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
