package hello.world;

import java.io.Serializable;

public class HelloWorld implements Serializable {

	public static final double D = 2.2;

	private int i = 2;

	{
		System.out.println(i + 2);
	}

	enum NUM {
		ONE, TWO, TRHEE;
	}

	protected void varargsMethod(int... ints) {
		int i = true ? 1 : 0;
	}

	@Deprecated
	public void setX(String x) {
		System.out.println(x);
	}

	public String getX() {
		return "x";
	}

	public static void main(String[] args) {
		for (String s : args) {
			System.out.println(s);
		}

		if (args.length > 0 || "".length() > 0) {
			System.out.println("if");
			if (true) {
				System.out.println("true");
			}
		} else {
			System.out.println("else");
		}
	}
	
	public static void main2(String[] args) {
		for (String s : args) {
			System.out.println(s);
		}

		if (args.length > 0 || "".length() > 0) {
			System.out.println("if");
			if (true) {
				System.out.println("true");
			}
		} else {
			System.out.println("else");
		}
	}

	public void test() {
		String str = "someString";
		if (str.equals("case1"))
			System.out.println("case1");

		if (str.equals("case2"))
			System.out.println("case2");
		else
			System.out.println("else");
	}

	public void wikiTest() {
		if (c1())
			f1();
		else
			f2();

		if (c2())
			f3();
		else
			f4();
	}

	private void f4() {
		// TODO Auto-generated method stub
		
	}

	private void f3() {
		// TODO Auto-generated method stub
		
	}

	private boolean c2() {
		// TODO Auto-generated method stub
		return false;
	}

	private void f2() {
		// TODO Auto-generated method stub
		
	}

	private void f1() {
		// TODO Auto-generated method stub
		
	}

	private boolean c1() {
		// TODO Auto-generated method stub
		return false;
	}
}