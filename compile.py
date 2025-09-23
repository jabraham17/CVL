#!/usr/bin/env python3

#
# Get the command line flags to use this library in your code
#

import sys
import os
import argparse as ap
from pathlib import Path

# use pip vendor TOML if no system TOML is available (Python 3.10 or less)
try:
    import tomllib
except ModuleNotFoundError:
    import pip._vendor.tomli as tomllib


def get_arch():
    machine = os.uname()[4]
    if machine == "aarch64":
        return "arm64"
    return machine


def get_os():
    platform = os.uname()[0]
    return platform.lower()


class Project:
    def __init__(self, workspace):
        self.workspace = workspace
        self.Mason_toml = workspace / "Mason.toml"
        self.data = {}
        self.sleef = False
        self.load()

    def load(self):
        with open(self.Mason_toml, "rb") as f:
            self.data = tomllib.load(f)

    def get_arch_compopts(self):
        arch = get_arch()
        arch_specific = self.data.get("architecture", {}).get(arch, None)
        arch_compopts = ""
        if arch_specific is None:
            sys.stderr.write("Unsupported architecture: {}\n".format(arch))
        else:
            arch_compopts = arch_specific.get("compopts", "")

        if self.sleef:
            sleef_dir = (
                self.workspace / "third-party" / "sleef" / "sleef-install"
            )
            if sleef_dir.exists():
                arch_compopts += (
                    " --set useSLEEF --set SLEEF_INSTALL='{}'".format(sleef_dir)
                )
                if get_os() == "linux":
                    # FIXME: sleef static libs are not PIE, so disable for now
                    arch_compopts += (
                        " --ccflags -Wno-unused-command-line-argument"
                        + " --ccflags -no-pie --ldflags -no-pie"
                    )
            else:
                install_script = (
                    self.workspace / "third-party" / "sleef" / "install.sh"
                )
                sys.stderr.write(
                    "Sleef directory not found: {}, try running {}`\n".format(
                        sleef_dir, install_script
                    )
                )
                exit(1)

        return arch_compopts

    def get_mason_compopts(self):
        compopts = self.data["brick"].get("compopts", "")
        return compopts

    def get_module_compopts(self):
        src = self.workspace / "src"
        module_compopts = "-M{}".format(src)
        return module_compopts

    def get_compopts(self):
        module_compopts = self.get_module_compopts()
        mason_compopts = self.get_mason_compopts()
        arch_compopts = self.get_arch_compopts()
        return "{} {} {}".format(module_compopts, mason_compopts, arch_compopts)

    def get_docopts(self):
        docopts = self.data["brick"].get("docopts", "")
        return docopts

    def get_tests(self):
        tests = self.data["brick"].get("tests", "")
        return tests

    def generate_ops(self):
        sys.path.insert(0, str(self.workspace / "util"))
        from generate_ops import Parser, BinaryOpsGenerator

        expressions = Parser(self.workspace / "src" / "Vector.chpl").parse()
        generator = BinaryOpsGenerator(expressions)
        generator.generate(self.workspace / "src" / "Vector" / "Operators.chpl")


def main():

    cvl_directory = Path(__file__).resolve().parent
    project = Project(cvl_directory)

    a = ap.ArgumentParser()
    a.add_argument(
        "--module-compopts",
        const=project.get_module_compopts,
        dest="action",
        action="store_const",
        default=project.get_compopts,
    )
    a.add_argument(
        "--base-compopts",
        const=project.get_mason_compopts,
        dest="action",
        action="store_const",
        default=project.get_compopts,
    )
    a.add_argument(
        "--arch-compopts",
        const=project.get_arch_compopts,
        dest="action",
        action="store_const",
        default=project.get_compopts,
    )
    a.add_argument(
        "--all-compopts",
        const=project.get_compopts,
        dest="action",
        action="store_const",
        default=project.get_compopts,
    )
    a.add_argument(
        "--docopts",
        const=project.get_docopts,
        dest="action",
        action="store_const",
        default=project.get_compopts,
    )
    a.add_argument(
        "--list-tests",
        const=project.get_tests,
        dest="action",
        action="store_const",
        default=project.get_compopts,
    )
    a.add_argument(
        "--generate-ops",
        const=project.generate_ops,
        dest="action",
        action="store_const",
        default=project.get_compopts,
    )
    a.add_argument(
        "--sleef",
        default=False,
        action="store_true",
        help="Use the Sleef library for vector math operations",
    )
    args = a.parse_args()
    project.sleef = args.sleef

    res = args.action()
    if res:
        print(res)


if __name__ == "__main__":
    main()
