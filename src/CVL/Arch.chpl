module Arch {
  import ChplConfig;
  proc isX8664() param: bool do return ChplConfig.CHPL_TARGET_ARCH == "x86_64";
  proc isArm64() param: bool do
    return ChplConfig.CHPL_TARGET_ARCH == "arm64" ||
           ChplConfig.CHPL_TARGET_ARCH == "aarch64";
}
