#!/bin/bash
# Need to use gnu parallel to limit number of these running at once (for memory reasons)
# parallel -j+0 'sh runbatch_BF.sh' ::: {1..10} 
# We sleep a bit to prevent writing at the same time...

# Run with file input
webppl BF.wppl --require ./refModule/ -- --modelVersion colorSize --constraint yokeCosts
# > "out.tmp"; sleep $(( $RANDOM/10000 ));
