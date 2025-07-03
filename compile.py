#!/usr/bin/env python3

# 
# Get the command line flags to use this library in your code
# 

import sys
import os
import argparse as ap
from pathlib import Path
# use pip vendor TOML if no system TOML is available (Python 3.10 or less)
try: import tomllib
except ModuleNotFoundError: import pip._vendor.tomli as tomllib

def get_arch():
    machine = os.uname()[4]
    if machine == "aarch64":
        return "arm64"
    return machine

class Compopts:
    def __init__(self, workspace):
        self.workspace = workspace
        self.Mason_toml = workspace / "Mason.toml"
        self.data = {}
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


def main():

    cvi_directory = Path(__file__).resolve().parent
    compopts = Compopts(cvi_directory)

    a = ap.ArgumentParser()
    a.add_argument("--module-compopts", const=compopts.get_module_compopts, dest="action",action="store_const", default=compopts.get_compopts)
    a.add_argument("--base-compopts", const=compopts.get_mason_compopts, dest="action",action="store_const", default=compopts.get_compopts)
    a.add_argument("--arch-compopts", const=compopts.get_arch_compopts, dest="action",action="store_const", default=compopts.get_compopts)
    a.add_argument("--all-compopts", const=compopts.get_compopts, dest="action",action="store_const", default=compopts.get_compopts)
    args = a.parse_args()

    print(args.action())


if __name__ == "__main__":
    main()
