#!/usr/bin/env python3

import os
import sys
import glob
from pathlib import Path

PROJECT_DIR = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_DIR))

TEST_DIR = PROJECT_DIR / "test"

# list all tests from mason
import compile as ProjectScript
mason_tests = ProjectScript.Project(PROJECT_DIR).get_tests()
mason_tests = [TEST_DIR / t for t in mason_tests]

# list all .chpl files in TEST_DIR
files = TEST_DIR.glob("**/*.chpl")

# exclude cmake dir
cmake_dir = TEST_DIR / "cmake"
files = [f for f in files if os.path.commonprefix((cmake_dir, f)) != str(cmake_dir)]

# exclude TestHelpers.chpl
TestHelpers = TEST_DIR / "TestHelpers.chpl"
files = [f for f in files if f != TestHelpers]

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
