# File overview

- `clickedObj` contains all listener side raw files
- `message` contains all speaker side raw files
- `parseMessages.py` generates `rawdata_exp1_exp3.csv` from the raw files
- `mturk_exp1_exp3.csv` contains comments by the subjects recruited via Amazon Mechanical Turk 
- `rawdata_exp1_exp3.csv` is fed into `../../../analysis/preprocessing_exp1.R` to generate `data_exp1_preManualTypoCorrection.csv`
- `data_exp1_preManualTypoCorrection.csv` was manually corrected for typos etc (see paper) by Caroline Graf, yielding `data_exp1_postManualTypoCorrection.csv`
- `data_exp1_postManualTypoCorrection.csv` is fed into `../../../analysis/preprocessing_exp1.R` to generate data file `../../data_exp1` that the regression analyses and Bayesian data analyses are based on.
- `rawdata_exp1_exp3.csv` is fed into `../../../analysis/preprocessing_exp3.R` to generate `data_exp3_preManualTypoCorrection.csv`
- `data_exp3_preManualTypoCorrection.csv` was manually corrected for typos etc (see paper) by Caroline Graf, yielding `data_exp3_postManualTypoCorrection.csv`
- `data_exp3_postManualTypoCorrection.csv` is fed into `../../../analysis/preprocessing_exp3.R` to generate data file `../../data_exp3` that the regression analyses and Bayesian data analyses are based on.
