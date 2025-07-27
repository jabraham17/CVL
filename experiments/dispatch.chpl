
use Reflection;

record Base {
  type impl;
  inline proc type foo() {
    if canResolveTypeMethod(impl, "foo") {
      impl.foo();
    } else {
      writeln("Base.foo");
    }
  }
  inline proc type bar() {
    if canResolveTypeMethod(impl, "bar") {
      impl.bar();
    } else {
      writeln("Base.bar");
    }
  }
}

record Impl1 {
  type base;
  inline proc type bar() {
    writeln("Impl1.bar");
    base.foo(); // dispatches to Base.foo
  }

}



record Impl2 {
  type base;
  inline proc type bar() {
    writeln("Impl2.bar");
    base.foo(); // dispatches to Impl2.foo
    }
  inline proc type foo() {
    writeln("Impl2.foo");
  }
}

proc get1 type do
  return Base(Impl1(Base(Impl1(nothing))));
proc get2 type do
  return Base(Impl2(Base(Impl2(nothing))));



type t = get1;
t.bar();
writeln();
get2.bar();
