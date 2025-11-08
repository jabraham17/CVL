
use Reflection;

record myImplType {
  type extension;
  inline proc type myMethod() {
    if canResolveTypeMethod(extension, "myMethod") then
      extension.myMethod();
    else
      writeln("Base implementation");
  }
  inline proc type printMe() {
    writeln("Hello, world!");
  }
}

record myExtensionType {
  type base;
  inline proc type myMethod() {
    writeln("Extension implementation");
    base.printMe();
  }
}

proc myType type do
  return myImplType(myExtensionType(myImplType(myExtensionType(nothing))));

myType.myMethod();
