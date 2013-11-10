package very.simple;
import java.*;
import java.awt.*;
//3
/**
 * Total Nr of SLOC in this class: TBD
 * 
 * Copyright 2013 Yosuf Haydary
 * 
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License. *
 */
public class Printer {
	//4
	
	public static int nr=0;
	//5
	
	public static void main(String arg) {
		//7
		System.out.println("Print a line");
		//6
	}

	
	public void test(){
		
	}
	//8
	
	private static int getNr(){
		//9
		return 0;
		//10
	}

	
	public void trier(int b){
		//11
		
		try{
		//12
			
		}catch(Exception e){
			//13
		}
		
	}
	
	public void ifElse(){
		//14
		
		if(false){
			//15
			
			ifElse();
			ifElse();
			//17
			
		} 
		else if(true){
			//18
			trier(4);
			//19
		} 	
		/**
		 * Why is the else block not taken into account?
		 */
		else { 
//			//20
			trier(4);
//			//21
		}
	
	}

	public void sync(){
		//22
		String lock= "";
		//23
		
		synchronized (lock) {
		//24
			
		 ifElse();
		 //25
		}
		
		synchronized (lock) {
			//26
		}
	}

	public void vars(){
		//27
		
		int nr = 5;
		//28
		
		nr = getNr();
		//29

		nr = getNr()+getNr()+getNr();
		//30
	}
	
	public void loops(){
		//31
		
		for(int i=0; i<5; i++){
			//32
			
			System.out.println("i: "+i);
			//33
		}
		
		while(true){
			//34
			
			getNr();
			//35
		}
	}
	
	
	public Printer() {
		//36
		super();
		//37
	}
	
	
	public class SimpleInnerClass{
		//38		
	}
	
	
}

