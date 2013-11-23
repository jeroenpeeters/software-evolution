package very.simple;
import very.SimpleInterface;
//2

public class SimpleClass implements SimpleInterface {
//3
	
	@Override
	//4
	public int simpleInt(int i) throws RuntimeException {
	//5	
		return 0;
		//6
	}

	@Override
	//7
	public void simpleVoid() {
	//8
		String str;
		//9
		
		str = "";
		//10
		
	}
	
	@Deprecated
	//11
	public void whileLoop(){
		//12
		
		while(true){
			//13
			
			break;
			//14
		}
		
		synchronized (SIMPLE_STRING) {
		//15	
		}
		
	}

}
