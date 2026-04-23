module CVL {
  config param implementationWarnings = true;
  // public
  include module Vector;
  include module VectorRef;

  // helpers
  include module Arch;
  include module Intrin;
  include module IntrinArm64_128;
  include module IntrinArm64_256;
  include module IntrinX86_128;
  include module IntrinX86_256;
  include module SLEEF;

  public use Vector;
  public use VectorRef;
}
