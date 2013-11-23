module series1::utils

import lang::java::m3::AST;

@doc{
Produces the Fully Qualified package name as a string by recursively unfolding the package nodes in the AST.
}
public str fqPackageName(package(str name)) = name;
public str fqPackageName(package(Declaration parent, str name)) = "<fqPackageName(parent)>.<name>";