module yosuf::Volume

	bool printEnabled = true;

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
    }
    return count;
}

/**
* Originally from Jeroen's idea where node is printed.
*/
public void print(str arg){
	 if(printEnabled){
	   println(arg);
	 }
	}