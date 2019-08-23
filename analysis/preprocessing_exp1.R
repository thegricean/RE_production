this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

# Automatic preprocessing of data from Exp. 1
library(tidyverse)
source("helper_scripts/helpers.R")

# Read raw data and get only trials from Exp. 1
d = read.table(file="../data/raw/production_exp1_exp3/rawdata_exp1_exp3.csv",sep="\t", header=T, quote="")
colsize = droplevels(d[d$trialType == "colorSizeTrial",])
colsizerows = nrow(colsize)
head(colsize)

# Was a color mentioned?
colsize$colors = ifelse(grepl("green|purple|white|black|brown|violet|yellow|gold|orange|silver|blue|pink|red", colsize$refExp, ignore.case = TRUE), T, F)
table(colsize$colors)

# Was a size mentioned?
colsize$sizes = ifelse(grepl("big|small|bigger|smaller|tiny|huge|large|larger|little|biggest|smallest|largest", colsize$refExp, ignore.case = TRUE), T, F)
table(colsize$sizes)

# Was the object's type (noun) mentioned?
colsize$types = ifelse(grepl("avocado|balloon|cap|belt|bike|billiardball|binder|book|bracelet|bucket|butterfly|candle|chair|coat hanger|comb|cushion|guitar|flower|frame|golf ball|hair dryer|jacket|napkin|ornament|pepper|phone|rock|rug|shoe|stapler|tack|teacup|toothbrush|turtle|wedding cake|yarn", colsize$refExp, ignore.case = TRUE), T, F)
table(colsize$types)

# Was a bleached noun used?
colsize$oneMentioned = ifelse(grepl(" one|thing|item|object", colsize$refExp, ignore.case = TRUE), T, F)
table(colsize$oneMentioned)

# Was an article used?
colsize$theMentioned = ifelse(grepl("the |a |an ", colsize$refExp, ignore.case = TRUE), T, F)
table(colsize$theMentioned)

# Write this dataset for manual correction of typos like "pruple"
write.table(colsize,file="../data/raw/production_exp1_exp3/data_exp1_preManualTypoCorrection.csv", sep="\t",quote=F,row.names=F)

# Read CG's manually corrected dataset for further preprocessing
d = read.table(file="../data/raw/production_exp1_exp3/data_exp1_postManualTypoCorrection.csv",sep=",", header=T, quote="")  
### Note that 6 trials of participants with game-id 2370-c were excluded during manual processing due to speaker non-compliance (i.e., missing speaker utterances while correctly selecting target objects)

head(d)
colsizerows = nrow(d)

# How many trials were automatically labelled as mentioning a pre-coded level of reference?
auto_trials = sum(d$automaticallyLabelledTrial)
print(paste("percentage of automatically labelled trials: ", auto_trials*100/colsizerows)) # 95.7

# How many trials were manually labelled as mentioning a pre-coded level of reference? (overlooked by grep search due to typos or grammatical modification of the expression)
manu_trials = sum(d$manuallyAddedTrials)
print(paste("percentage of manually added trials: ", manu_trials*100/colsizerows)) # 1.9

# How often were articles omitted?
no_article_trials = colsizerows - sum(d$typeMentioned)
print(paste("percentage trials where articles were omitted: ", no_article_trials*100/colsizerows)) # 71.6

# How often were nouns omitted?
d$article_mentioned = ifelse(d$oneMentioned == TRUE | d$theMentioned == TRUE, 1, 0)
no_noun_trials = colsizerows - sum(d$article_mentioned)
print(paste("percentage of trials where nouns were omitted: ", no_noun_trials*100/colsizerows)) # 88.6

# In how many cases did the listener choose the wrong object?
colsizeCor = droplevels(d[!is.na(d$targetStatusClickedObj) & d$targetStatusClickedObj != "distractor",])
nrow(colsizeCor)
print(paste(100*(1-(nrow(colsizeCor)/colsizerows)),"% of cases of non-target choices")) # 1.5

# How many unique pairs?
length(levels(d$gameid)) # 64

# Code for each trial: sufficient property, number of total distractors, number of distractors that differ on and that share insufficient dimension value with target
d$SufficientProperty = as.factor(ifelse(d$condition %in% c("size21", "size22", "size31", "size32", "size33", "size41", "size42", "size43", "size44"), "size", "color"))
d$RedundantProperty = ifelse(d$SufficientProperty == 'color',"size redundant","color redundant")
d$NumDistractors = ifelse(d$condition %in% c("size21","size22","color21","color22"), 2, ifelse(d$condition %in% c("size31","size32","size33","color31","color32","color33"),3,4))
d$NumDiffDistractors = ifelse(d$condition %in% c("size22","color22","size33","color33","size44","color44"), 0, ifelse(d$condition %in% c("size21","color21","size32","color32","size43","color43"), 1, ifelse(d$condition %in% c("size31","color31","size42","color42"),2,ifelse(d$condition %in% c("size41","color41"),3, 4))))
d$NumSameDistractors = ifelse(d$condition %in% c("size21","size31","size41","color21","color31","color41"), 1, ifelse(d$condition %in% c("size22","size32","size42","color22","color32","color42"), 2, ifelse(d$condition %in% c("size33","color33","size43","color43"),3,ifelse(d$condition %in% c("size44","color44"),4,NA))))
d$SceneVariation = d$NumDiff/d$NumDistractors
d$TypeMentioned = d$typeMentioned

# Add empirical typicality ratings
# Add color typicality ratings ("how typical is this color for a stapler?" wording)
typicalities = read.table("../data/typicality_exp1_colortypicality.csv",header=T)
head(typicalities)
typicalities = typicalities %>%
  group_by(Item) %>%
  mutate(OtherTypicality = c(Typicality[2],Typicality[1]),OtherColor = c(as.character(Color[2]),as.character(Color[1])))
typicalities = as.data.frame(typicalities)
row.names(typicalities) = paste(typicalities$Item,typicalities$Color)
d$ColorTypicality = typicalities[paste(d$clickedType,d$clickedColor),]$Typicality
d$OtherColorTypicality = typicalities[paste(d$clickedType,d$clickedColor),]$OtherTypicality
d$OtherColor = typicalities[paste(d$clickedType,d$clickedColor),]$OtherColor
d$TypicalityDiff = d$ColorTypicality-d$OtherColorTypicality  
d$normTypicality = d$ColorTypicality/(d$ColorTypicality+d$OtherColorTypicality)

# Add typicality norms for objects with modified and unmodified utterances ("how typical is this for a stapler?" vs "how typical is this for a red stapler?" wording)
typs = read.table("../data/typicality_exp1_objecttypicality.csv",header=T)
head(typs)
typs = typs %>%
  group_by(Item) %>%
  mutate(OtherTypicality = c(Typicality[3],Typicality[4],Typicality[1],Typicality[2])) 
typs = as.data.frame(typs)
row.names(typs) = paste(typs$Item,typs$Color,typs$Modification)
d$ColorTypicalityModified = typs[paste(d$clickedType,d$clickedColor,"modified"),]$Typicality
d$OtherColorTypicalityModified = typs[paste(d$clickedType,d$clickedColor,"modified"),]$OtherTypicality
d$TypicalityDiffModified = d$ColorTypicalityModified-d$OtherColorTypicalityModified  
d$normTypicalityModified = d$ColorTypicalityModified/(d$ColorTypicalityModified+d$OtherColorTypicalityModified)
d$ColorTypicalityUnModified = typs[paste(d$clickedType,d$clickedColor,"unmodified"),]$Typicality
d$OtherColorTypicalityUnModified = typs[paste(d$clickedType,d$clickedColor,"unmodified"),]$OtherTypicality
d$TypicalityDiffUnModified = d$ColorTypicalityUnModified-d$OtherColorTypicalityUnModified  
d$normTypicalityUnModified = d$ColorTypicalityUnModified/(d$ColorTypicalityUnModified+d$OtherColorTypicalityUnModified)


# Reduce dataset to target trials for visualization and analysis

# Exclude trials on which target wasn't selected
targets = droplevels(d[!is.na(d$targetStatusClickedObj) & d$targetStatusClickedObj != "distractor",])
nrow(targets) # 2138 cases

# Categorize everything that isn't a size, color, or size-and-color mention as OTHER
targets$UtteranceType = as.factor(ifelse(targets$sizeMentioned & targets$colorMentioned, "size and color", ifelse(targets$sizeMentioned, "size", ifelse(targets$colorMentioned, "color","OTHER"))))

# examples of what people say when utterance is not clearly categorizable:
targets[targets$UtteranceType == "OTHER",]$refExp

targets = droplevels(targets)
table(targets$UtteranceType)
table(targets[targets$UtteranceType == "OTHER",]$gameid) 
targets$Color = ifelse(targets$UtteranceType == "color",1,0)
targets$Size = ifelse(targets$UtteranceType == "size",1,0)
targets$SizeAndColor = ifelse(targets$UtteranceType == "size and color",1,0)
targets$Other = ifelse(targets$UtteranceType == "OTHER",1,0)
targets$Item = sapply(strsplit(as.character(targets$nameClickedObj),"_"), "[", 3)
targets$redUtterance = as.factor(ifelse(targets$UtteranceType == "size and color","redundant",ifelse(targets$UtteranceType == "size" & targets$SufficientProperty == "size", "minimal", ifelse(targets$UtteranceType == "color" & targets$SufficientProperty == "color", "minimal", "other"))))
targets$RatioOfDiffToSame = targets$NumDiffDistractors/targets$NumSameDistractors
targets$DiffMinusSame = targets$NumDiffDistractors-targets$NumSameDistractors


# Prepare data for Bayesian Data Analysis by collapsing across specific size and color terms
targets$redUtterance = as.factor(as.character(targets$redUtterance))
targets$CorrectProperty = ifelse(targets$SufficientProperty == "color" & (targets$Color == 1 | targets$SizeAndColor == 1), 1, ifelse(targets$SufficientProperty == "size" & (targets$Size == 1 | targets$SizeAndColor == 1), 1, 0)) # 20 cases of incorrect property mention
targets$minimal = ifelse(targets$SizeAndColor == 0 & targets$UtteranceType != "OTHER", 1, 0)
targets$redundant = ifelse(targets$SizeAndColor == 1, 1, 0)
targets$BDAUtterance = "size"#as.character(targets$clickedSize)
targets[targets$Color == 1,]$BDAUtterance = as.character(targets[targets$Color == 1,]$clickedColor)
targets[targets$SizeAndColor == 1,]$BDAUtterance = paste("size",targets[targets$SizeAndColor == 1,]$clickedColor,sep="_")
targets$redBDAUtterance = "size_color"
targets[targets$Color == 1,]$redBDAUtterance = "color"
targets[targets$Size == 1,]$redBDAUtterance = "size"
targets[targets$Other == 1,]$redBDAUtterance = "other"
targets$BDASize = "size"
targets$BDAColor = "color"
targets$BDAFullColor = targets$clickedColor
targets$BDAOtherColor = "othercolor"
targets$BDAItem = "item"

# Code non-sensical and "closest"/"Farthest" cases
targets[targets$redBDAUtterance != "other" & targets$CorrectProperty == 0,c("gameid","condition","nameClickedObj","refExp")]
targets$WeirdCases = FALSE
targets[targets$redBDAUtterance != "other" & targets$CorrectProperty == 0  & !targets$gameid %in% c("3791-8","7569-e"),]$WeirdCases = TRUE

# Write Bayesian data analysis files (data and unique conditions)
write.csv(targets[targets$redBDAUtterance != "other" & targets$WeirdCases == FALSE,c("gameid","roundNum","condition","BDASize","BDAColor","BDAOtherColor","BDAItem","redBDAUtterance")],file="../models/bdaInput/colorSize/bda_data.csv",quote=F,row.names=F)
write.csv(unique(targets[targets$redBDAUtterance != "other" & targets$WeirdCases == FALSE,c("BDAColor","BDASize","condition","BDAOtherColor","BDAItem")]),file="../models/bdaInput/colorSize/unique_conditions.csv",quote=F,row.names=F)

# Write file for regression analysis and visualization (this includes the 6 cases where the insufficient dimension was underinformatively mentioned)
dd = targets %>%
  filter(redUtterance != "other" & WeirdCases == FALSE) %>%
  rename(Trial=roundNum, TargetItem=nameClickedObj) %>%
  select(gameid,Trial,TargetItem,UtteranceType,redUtterance,SufficientProperty,RedundantProperty,NumDistractors,NumSameDistractors,SceneVariation,speakerMessages,listenerMessages,refExp,minimal,redundant,clickedType,clickedSize,clickedColor,colorMentioned,sizeMentioned,typeMentioned,oneMentioned,theMentioned,ColorTypicality,OtherColorTypicality,OtherColor,TypicalityDiff,normTypicality,ColorTypicalityModified,ColorTypicalityUnModified,OtherColorTypicalityModified,OtherColorTypicalityUnModified,TypicalityDiffModified,normTypicalityModified,TypicalityDiffUnModified,normTypicalityUnModified,alt1Name,alt1SpLocs,alt1LisLocs,alt2Name,alt2SpLocs,alt2LisLocs,alt3Name,alt3SpLocs,alt3LisLocs,alt4Name,alt4SpLocs,alt4LisLocs)
nrow(dd)

write.table(dd, file="../data/data_exp1.csv",sep="\t",quote=F,row.names=F)


##########################################################
## Supplementary preprocessing: analyze MTurk meta-data ##
##########################################################

# Turker comments
comments = read.table(file="../data/raw/production_exp1_exp3/mturk_exp1_exp3.csv",sep=",", header=T, quote="")
unique(comments$comments)

# Partner rating
ggplot(comments, aes(ratePartner)) +
  geom_histogram(stat='count')

# Did they think their partner was a human?
ggplot(comments, aes(thinksHuman)) +
  geom_histogram(stat='count')
prop.table(table(comments$thinksHuman))
table(comments$thinksHuman)

# Native language
ggplot(comments, aes(nativeEnglish)) +
  geom_histogram(stat='count')

# Total length of experiment
ggplot(comments, aes(totalLength)) +
  geom_histogram()

comments$lengthInMinutes = (comments$totalLength/1000)/60
summary(comments$lengthInMinutes)
