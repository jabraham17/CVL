#!/usr/bin/env bash


chpl --fast flux.chpl -o flux &
chpl --fast --no-ieee-float flux.chpl -o flux_no_ieee &
chpl --fast flux2.chpl -o flux2 &
chpl --fast --no-ieee-float flux2.chpl -o flux2_no_ieee &
chpl --fast flux3.chpl $(/Users/jade/Development/SIMDLibrary/compile.py) -o flux3 &
chpl --fast --no-ieee-float flux3.chpl $(/Users/jade/Development/SIMDLibrary/compile.py) -o flux3_no_ieee &
wait

ARGS='--timing --n=10_000 --m=10_000'
set -x
hyperfine "./flux $ARGS" "./flux_no_ieee $ARGS"
hyperfine "./flux2 $ARGS" "./flux2_no_ieee $ARGS"
hyperfine "./flux3 $ARGS" "./flux3_no_ieee $ARGS"

hyperfine "./flux3 $ARGS" "./flux $ARGS"
