#!/bin/bash
# Need to use gnu parallel to limit number of these running at once (for memory reasons)
# find ../bdaInput/*.csv | parallel -j 4 --bar "sh runbatch_BF.sh" {}
# We sleep a bit to prevent writing at the same time...

# Run with file input
webppl BF.wppl --require ./refModule/ -- --modelVersion colorSize --constraint yokeCosts
# > "out.tmp"; sleep $(( $RANDOM/10000 ));
