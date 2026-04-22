#!/usr/bin/env python3

import sys
from pathlib import Path

PROJECT_DIR = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_DIR))

TEST_DIR = PROJECT_DIR / "test"

try:
    import tomllib
except ModuleNotFoundError:
    import pip._vendor.tomli as tomllib

with open(PROJECT_DIR / "Mason.toml", "rb") as f:
    toml_data = tomllib.load(f)

# read the mason tests from the toml
mason_tests = [TEST_DIR / t for t in toml_data["tests"]]

# list all .chpl files in TEST_DIR
files = TEST_DIR.glob("**/*.chpl")

# exclude TestHelpers.chpl
TestHelpers = "TestHelpers.chpl"
files = [f for f in files if f.name != TestHelpers]

# the two lists should be the same
difference = set(mason_tests).difference(set(files))
difference_rev = set(files).difference(set(mason_tests))
if difference:
    print("Some tests listed in Mason.toml are not found")
    for f in difference:
        print(f"  {f.relative_to(PROJECT_DIR)}")
if difference_rev:
    print("Some files found in test dir not listed in Mason.toml")
    for f in difference_rev:
        print(f"  {f.relative_to(PROJECT_DIR)}")

exit(int(len(difference) > 0 or len(difference_rev) > 0))
