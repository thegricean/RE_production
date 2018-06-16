# Data

This directory contains all the data files required to reproduce the analyses reported in the paper. Raw data can be found in `raw`.

## Production

The data files that the mixed effects analyses and data visualizations for Exp. 1 - 3 are based on are `data_expX.csv`. You can reproduce the analyses and visualizations using the R scripts in `../analysis/analysis_expX.R`. The raw data files are stored in `raw/production_expX` and were preprocessed using the scripts in `../analysis/preprocessing_expX.R`.

## Typicality norming

The data files from the typicality norming studies are stored in `typicality_expX(_TYPE)`. They contain means and 95% CIs for each item and can be reproduced from the raw data files with the R scripts stored in `raw/norming_expX/*/norming.R`.

## Cost 

The data files containing cost information for utterances in Exp. 2 - 3 are `cost_expX.csv`. Relevant cost information is the log probability of the utterance (column `frq`) and mean length of the utterance in characters (`length`). These files can be reproduced by running FIXME and `../analysis/preprocessing_exp3.R` for experiment 2 and experiment 3, respectively.
