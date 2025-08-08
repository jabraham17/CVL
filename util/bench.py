#!/usr/bin/env python3

import argparse
from enum import Enum
import itertools
import json
import subprocess
import time
import statistics
import sys
from pathlib import Path
from typing import List, Dict, Optional, Self
from pydantic import BaseModel, Field
import tempfile
import re


class Language(str, Enum):
    CHPL = "chpl"
    C_GCC = "c-gcc"
    CPP_GCC = "cpp-gcc"
    C_CLANG = "c-clang"
    CPP_CLANG = "cpp-clang"

    def get_compiler(self) -> str:
        m = {
            Language.CHPL: "chpl",
            Language.C_GCC: "gcc",
            Language.CPP_GCC: "g++",
            Language.C_CLANG: "clang",
            Language.CPP_CLANG: "clang++",
        }
        return m[self]


class Stats(BaseModel):
    n: int
    mean: float
    stddev: float
    min: float
    max: float
    name: Optional[str] = None


class BenchmarkVersion(BaseModel):
    name: str
    files: List[str]
    language: Language
    compopts: List[str] = Field(default_factory=list)
    execopts: List[str] = Field(default_factory=list)
    measure: List[str] = Field(default_factory=list)

    def resolve_compopts(self, cvl_options: Optional[str] = None):
        # if CVL_OPTIONS in the compopts, remove it and add the CVL_OPTIONS
        if cvl_options and "CVL_OPTIONS" in self.compopts:
            self.compopts.remove("CVL_OPTIONS")
            self.compopts.extend(cvl_options.split())
        return self.compopts

class BenchmarkConfig(BaseModel):
    name: str
    trials: int = 1
    versions: List[BenchmarkVersion]


class BenchmarkSchema(BaseModel):
    benchmarks: List[BenchmarkConfig]

    @classmethod
    def from_file(cls, schema_path: str) -> Self:
        with open(schema_path, "r") as f:
            data = json.load(f)
            # Convert the flat dictionary into our expected structure
            return cls(**data)


class BenchmarkRun:
    """
    Run a single benchmark version and report the results
    """

    def __init__(
        self,
        benchmark_dir: Path,
        config: BenchmarkConfig,
        version: BenchmarkVersion,
    ):
        self.benchmark_dir = benchmark_dir
        self.config = config
        self.version = version
        self.measurements = {}

    def run(
        self, scratch: Optional[Path] = None, trials: Optional[int] = None
    ) -> bool:
        self.measurements = {}
        measure_regexes = {}
        for measure in self.version.measure:
            if measure == "RUNTIME":
                self.measurements["RUNTIME"] = []
            else:
                measure_regexes[measure] = re.compile(measure)
                self.measurements[measure] = []


        files = [str(self.benchmark_dir / f) for f in self.version.files]
        compopts = self.version.compopts
        execopts = self.version.execopts

        if scratch is None:
            executable_dir = Path(tempfile.mkdtemp())
        else:
            executable_dir = scratch
            executable_dir.mkdir(parents=True, exist_ok=True)
        executable_name = self.config.name + "__" + self.version.name
        executable_path = executable_dir / executable_name

        compiler = self.version.language.get_compiler()

        compile_cmd = (
            [compiler] + compopts + files + ["-o", str(executable_path)]
        )

        cc_str = " ".join(compile_cmd)
        print(f"Compiling {self.config.name}::{self.version.name} ({cc_str})")

        try:
            subprocess.run(
                compile_cmd, check=True, capture_output=True, text=True
            )
        except subprocess.CalledProcessError as e:
            print(f"Compilation failed: {e.stderr}", file=sys.stderr)
            return False

        run_cmd = [str(executable_path)]
        if self.version.language == Language.CHPL:
            run_cmd += ["-nl1"]
        run_cmd += execopts

        run_str = " ".join(run_cmd)
        print(f"Running {self.config.name}::{self.version.name} ({run_str})")

        try:
            trials = self.config.trials if trials is None else trials
            for trial in range(trials):
                print(f"Trial {trial + 1}/{trials}")
                start_time = time.time()
                cp = subprocess.run(run_cmd, check=True, capture_output=True, text=True)
                end_time = time.time()
                elapsed_time = end_time - start_time
                if "RUNTIME" in self.measurements:
                    self.measurements["RUNTIME"].append(elapsed_time)
                output = cp.stdout + cp.stderr
                for key, val in measure_regexes.items():
                    if match := val.search(output):
                        self.measurements[key].append(float(match.group(1)))
                    else:
                        print(
                            f"Warning: Could not find measurement '{key}' in output",
                            file=sys.stderr,
                        )
                print(
                    f"Trial {trial + 1} completed in {elapsed_time:.3f} seconds"
                )
        except subprocess.CalledProcessError as e:
            print(f"Execution failed: {e.stderr}", file=sys.stderr)
            return False
        finally:
            if scratch is None:
                executable_path.unlink()

        return True

    def stats(self, measurement="RUNTIME") -> Stats:

        if measurement not in self.measurements:
            raise ValueError(f"Measurement '{measurement}' not found")

        times = self.measurements[measurement]

        mean = statistics.mean(times)
        stddev = statistics.stdev(times) if len(times) > 1 else 0
        min_time = min(times)
        max_time = max(times)
        return Stats(
            n=len(times),
            mean=mean,
            stddev=stddev,
            min=min_time,
            max=max_time,
            name=measurement if measurement != "RUNTIME" else None,
        )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run benchmarks specified in a JSON schema"
    )
    parser.add_argument(
        "--schema",
        type=str,
        required=True,
        help="Path to benchmarks JSON schema",
    )
    parser.add_argument(
        "--filter",
        action="append",
        default=[],
        help="Filter benchmarks to run. "
        + "Format: benchmark::version or benchmark. "
        + "Can be specified multiple times.",
    )
    parser.add_argument("--cvl-options", type=str, default="")
    parser.add_argument("--scratch", type=Path, default=None)
    parser.add_argument(
        "--trials",
        type=int,
        default=None,
        help="Override the default trials for each benchmarks",
    )
    return parser.parse_args()


def load_schema(schema_path: str) -> BenchmarkSchema:
    return BenchmarkSchema.from_file(schema_path)


def should_run_benchmark(
    benchmark_name: str, version_name: str, filters: List[str]
) -> bool:
    if not filters:  # If no filters, run everything
        return True

    for f in filters:
        if "::" in f:
            b, v = f.split("::", 1)
            if b == benchmark_name and v == version_name:
                return True
        else:
            if f == benchmark_name:
                return True
    return False


def group_results_by_benchmark(
    results: Dict[str, List[Stats]],
) -> Dict[str, Dict[str, List[Stats]]]:
    grouped = {}
    for full_name, stats in results.items():
        benchmark, version = full_name.split("::")
        if benchmark not in grouped:
            grouped[benchmark] = {}
        grouped[benchmark][version] = stats
    return grouped


def print_statistics(results: Dict[str, List[Stats]]):
    print("\nResults by Benchmark:")
    print("=" * 100)

    grouped = group_results_by_benchmark(results)

    for benchmark, versions in grouped.items():
        if not versions:
            continue

        print(f"\nBenchmark: {benchmark}")
        header =  (f"{'Version':<40} {'Mean (s)':<12} {'Std Dev':<12} " +
            f"{'Min (s)':<12} {'Max (s)':<12} {'%% diff':<20}")
        print("-" * len(header))
        print(header
        )
        print("-" * len(header))

        # Sort versions by mean execution time
        # sorted_versions = sorted(versions.items(), key=lambda x: x[1].mean)
        # flatten the list of Stats (one per measurement)
        flattened_versions = itertools.chain.from_iterable(
            [(version, stat) for stat in stats] for version, stats in versions.items()
        )
        sorted_versions = sorted(flattened_versions, key=lambda x: x[1].mean)

        first = sorted_versions[0]
        for version, stats in sorted_versions:
            # Print basic statistics
            # Calculate percent difference against first version
            percent_diff = (
                ((stats.mean - first[1].mean) / first[1].mean) * 100
                if first[1].mean != 0
                else float("inf")
            )
            version_name = f"{version} - '{stats.name}'" if stats.name else version
            stats_line = (
                f"{version_name:<40} {stats.mean:<12.3f} "
                + f"{stats.stddev:<12.3f} {stats.min:<12.3f} "
                + f"{stats.max:<12.3f} {percent_diff:<20.3f}"
            )
            print(stats_line)

        print()


def main():
    args = parse_args()
    schema = load_schema(args.schema)
    benchmark_dir = Path(args.schema).parent
    runners = {}

    cvl_options = args.cvl_options

    for benchmark in schema.benchmarks:
        for version in benchmark.versions:
            full_name = f"{benchmark.name}::{version.name}"
            if should_run_benchmark(benchmark.name, version.name, args.filter):
                version.resolve_compopts(cvl_options)
                runners[full_name] = BenchmarkRun(
                    benchmark_dir, benchmark, version
                )

    results = {}
    for name, runner in runners.items():
        print(f"Running benchmark: {name}")
        if not runner.run(scratch=args.scratch, trials=args.trials):
            return 1  # error
        results[name] = list([runner.stats(measurement) for measurement in runner.measurements])

    print_statistics(results)


if __name__ == "__main__":
    ret = main()
    exit(0 if ret is None else ret)
