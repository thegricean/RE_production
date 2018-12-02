#!/bin/bash#
# parallel --bar --colsep ',' "sh ./run_BDA.sh {1} {2} {3} {4}" :::: bdaInput/nominal/bda-nominal.txt
webppl BDA.wppl --require ./refModule/ -- --modelVersion $1 --costs $2 --semantics $3 --chainNumber $4
