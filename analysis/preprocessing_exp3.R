# Automatic preprocessing of data from Exp. 3
library(tidyverse)
source("helper_scripts/helpers.R")

# Read raw data
d = read.table(file="../data/raw/production_exp1_exp3/rawdata_exp1_exp3.csv",sep="\t", header=T, quote="")

# Get only trials from Exp. 3
exp3_raw = droplevels(d[d$trialType == "subSuperTrial",])
exp3rows = nrow(exp3_raw)
head(exp3_raw)
summary(exp3_raw)
print(paste(exp3rows," trials were collected in total in experiment 3"))
# 2193

# Was a sub level term mentioned?
exp3_raw$sub = ifelse(grepl("bedside table|black bear|catfish|clownfish|coffee table|convertible|daisy|dalmatian|dining table|dress shirt|eagle|German Shepherd|goldfish|grizzly bear|gummybears|hawaii shirt|hummingbird|husky|jellybeans|M&Ms|minivan|panda bear|parrot|picnic table|pigeon|polar bear|polo shirt|pug|rose|skittles|sports car|sunflower|suv|swordfish|T-Shirt|tulip", exp3_raw$refExp, ignore.case = TRUE), T, F)
summary(exp3_raw)

# Was a basic level term mentioned?
exp3_raw$basic = ifelse(grepl("bear|bird|candy|car|dog|fish|flower|shirt|table", exp3_raw$refExp, ignore.case = TRUE), T, F)
summary(exp3_raw)

# Was a super level term mentioned?
exp3_raw$super = ifelse(grepl("animal|clothing|furniture|plant|vehicle|snack", exp3_raw$refExp, ignore.case = TRUE), T, F)
summary(exp3_raw)

# Was a bleached noun used?
exp3_raw$oneMentioned = ifelse(grepl(" one|thing|item|object", exp3_raw$refExp, ignore.case = TRUE), T, F)
summary(exp3_raw)

# Was an article used?
exp3_raw$theMentioned = ifelse(grepl("the |a |an ", exp3_raw$refExp, ignore.case = TRUE), T, F)
summary(exp3_raw)

# Write this dataset for manual correction of typos like "dalmation"
write.table(exp3_raw, file="../data/raw/production_exp1_exp3/data_exp3_preManualTypoCorrection.csv", sep="\t",quote=F,row.names=F)

###########################################################################################


# Read CG's manually corrected dataset for further preprocessing
exp3_post = read.table(file="../data/raw/production_exp1_exp3/data_exp3_postManualTypoCorrection.csv",sep=",", header=T, quote="") 
### Note that 6 trials of participants with game-id 2370-c were excluded during manual processing due to speaker non-compliance (i.e., missing speaker utterances while correctly selecting target objects)

head(exp3_post)

# How many unique pairs?
length(levels(exp3_post$gameid))

# How many trials were automatically labelled as mentioning a pre-coded level of reference?
auto_trials = sum(exp3_post$automaticallyLabelledTrial)
print(paste("percentage of automatically labelled trials: ", auto_trials*100/exp3rows)) # 71.4

# How many trials were manually labelled as mentioning a pre-coded level of reference? (overlooked by grep search due to typos or grammatical modification of the expression)
manu_trials = sum(exp3_post$manualAdditionTrial)
print(paste("percentage of manually added trials: ", manu_trials*100/exp3rows)) # 15.0


##### Reduce dataset to target trials for visualization and analysis #####

# Exclude trials on which target wasn't selected
exp3_post_targets = droplevels(exp3_post[!is.na(exp3_post$targetStatusClickedObj) & exp3_post$targetStatusClickedObj != "distractor",]) # 2.1
head(exp3_post_targets)
nrow(exp3_post_targets)
print(paste((1 - (nrow(exp3_post_targets)/exp3rows))*100,"% of cases were non-target choices, these incorrect trials were excluded."))

# How many trials contained *only* an attribute mention and no sub, basic, or super level?
only_attr_trials = sum(exp3_post_targets$onlyAttrMentioned)
print(paste("percentage of trials where only attribute was mentioned: ", only_attr_trials*100/exp3rows)) # 12.5

# Exclude only attribute mentions:
exp3_post_targets = droplevels(exp3_post_targets[exp3_post_targets$onlyAttrMentioned != TRUE,])
head(exp3_post_targets)
summary(exp3_post_targets)

# How many trials were included in the final analyses?
nrow(exp3_post_targets)
print(paste("Total number of trials used for final analysis: ", nrow(exp3_post_targets))) # 1872



# Write file for regression analysis and visualization 
final_d = exp3_post_targets %>%
  mutate(Trial=roundNum, target_sub = tolower(nameClickedObj), target_basic = tolower(basiclevelClickedObj), target_super = tolower(superdomainClickedObj), alt1_sub = tolower(alt1Name), alt1_basic = tolower(alt1Basiclevel), alt1_super = tolower(alt1superdomain), alt2_sub = tolower(alt2Name), alt2_basic = tolower(alt2Basiclevel), alt2_super = tolower(alt2superdomain)) %>%
  select(gameid,Trial,condition,target_sub,target_basic,target_super,speakerMessages,listenerMessages,
         refExp,sub,basic,super,alt1_sub,alt1_basic,alt1_super,alt2_sub,alt2_basic,alt2_super)
nrow(final_d)

final_d$redCondition = as.factor(ifelse(final_d$condition == "basic12","sub_necessary",ifelse(final_d$condition == "basic33","super_sufficient","basic_sufficient")))
final_d$binaryCondition = as.factor(ifelse(final_d$condition == "basic12","sub_necessary","nonsub_sufficient"))

write.table(final_d, file="../data/data_exp3.csv",sep="\t",quote=F,row.names=F)




### Some supplementary analyses:

# In how many trials where a sub level term was mentioned, was there in addition an attribute mentioned?
sub_add_attr_trials = sum(exp3_post$additionalAttrMentioned & exp3_post$sub)
sub_mentions = sum(exp3_post$sub)
print(paste("percentage of sub mentions where an additional modifier was used: ", sub_add_attr_trials*100/sub_mentions)) # 8.9

# In how many trials where a basic level term was mentioned, was there in addition an attribute mentioned?
basic_add_attr_trials = sum(exp3_post$additionalAttrMentioned & exp3_post$basic)
basic_mentions = sum(exp3_post$basic)
print(paste("percentage of basic mentions where an additional modifier was used: ", basic_add_attr_trials*100/basic_mentions)) # 18.9

# In how many trials where a super level term was mentioned, was there in addition an attribute mentioned?
super_add_attr_trials = sum(exp3_post$additionalAttrMentioned & exp3_post$super)
super_mentions = sum(exp3_post$super)
print(paste("percentage of super mentions where an additional modifier was used: ", super_add_attr_trials*100/super_mentions)) # 60.9

# In how many trials were two different levels of reference mentioned?
two_levels_trials = sum(exp3_post$moreThanOneLevelMentioned)
print(paste("percentage of trials where 2 levels were mentioned: ", two_levels_trials*100/exp3rows)) # 1.2




############################################################################

# Prepare data for Bayesian Data Analysis

tmp = exp3_post_targets[(exp3_post_targets$sub | exp3_post_targets$basic | exp3_post_targets$super) & exp3_post_targets$targetStatusClickedObj == "target",] %>%
  select(gameid, roundNum, condition, nameClickedObj, alt1Name, alt2Name, sub, basic, super) %>%
  mutate(targetName = tolower(nameClickedObj),
         alt1Name = tolower(alt1Name),
         alt2Name = tolower(alt2Name)) %>%
  mutate(refLevel = ifelse(sub, "sub",
                           ifelse(basic, "basic",
                                  ifelse(super, "super", "other")))) %>%
  select(gameid, roundNum, targetName, alt1Name, alt2Name, refLevel)

write.csv(tmp, "../models/bdaInput/exp3_bdaInput/nominal/bda_data.csv", row.names = F, quote = F)




############################################################################

### Add information on costs

## 1) Add frequencies from Google Books corpus and compute log frequency diffs for regression

frequencies = read.table(file="../data/raw/cost_exp3/exp3_frequency.csv",sep=",", header=T, quote="")
frequencies$target = as.factor(tolower(as.character(frequencies$noun))) # make labels uniform
frequencies$freq = frequencies$relFreq

frequencies = frequencies %>%
  select(target, freq)

## 2) Empirical lengths

# Read manual coding of speaker utterances:
lengths_extended = read.table(file="../data/raw/cost_exp3/exp3_length_manual_compilation.csv",sep=",", header=T, quote="")
lengths_extended$target = as.factor(tolower(as.character(lengths_extended$noun))) # make labels uniform
lengths_extended$length = lengths_extended$average_length

# (lengths_extended is a semi-manually created file that compiles the lengths of different instances of sub, 
# basic, and super mentions. Orgininally this should have been automatically; however, it turned out to be
# difficult to foresee which alternatives referring expressions would be uttered by participants 
# (i.e., many alternatives could not be automatically coded). 
# Thus this document lists all used speaker referring expressions used in our production experiment, 
# their length and their count, as well as the average empirical length and standard deviation.)

lengths = lengths_extended %>%
  select(target, length)

write.csv(lengths, "../data/raw/cost_exp3/exp3_length_uniform_labels.csv", row.names = F, quote = F)

## 3) Combine to cost file:

costs = full_join(frequencies, lengths, by="target")
write.csv(costs, "../data/cost_exp3.csv", row.names = F, quote = F)
