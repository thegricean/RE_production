#!/bin/bash#
# parallel --bar --colsep ',' "sh ./run_BF.sh {1} {2} {3}" :::: BFInput/BF_nominal.txt  > "BFOutput/BF_nominal.txt"
webppl BF.wppl --require ./refModule/ -- --modelVersion $1 --costs $2 --semantics $3
