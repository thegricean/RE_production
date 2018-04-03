library(here)

source(here("analysis","helper_scripts","helpers.R"))

# Read raw data
d = read.table(file=here("data","raw","production_exp2","rawdata_exp2.csv"),sep="\t", header=T, quote="")
nrow(d)
head(d)

# Exclude data and participants that cannot be used for analysis
# exclude NA referential expressions 
d = droplevels(d[!(is.na(d$refExp)),])
# unique(d$gameid): 59 pairs
# exclude participants that were not paid because they didn't finish it
d = droplevels(d[!(d$gameid == "6444-b" | d$gameid == "4924-4"), ])
# exclude pairs because listeners didn't respond
d = droplevels(d[!(d$gameid == "0960-e" | d$gameid == "6911-b" | d$gameid == "1866-f" | d$gameid == "6581-5"), ])
# exclude tabu players
d = droplevels(d[!(d$gameid == "1544-1" | d$gameid == "4885-8" | d$gameid == "8360-7" | d$gameid == "4624-5" | d$gameid == "5738-a" | d$gameid == "8931-5" | d$gameid == "8116-a" | d$gameid == "6180-c" | d$gameid == "1638-6" | d$gameid == "6836-b"), ])
# unique(d$gameid): 47 pairs
# exclude trials with distractor choices
d = droplevels(d[d$targetStatusClickedObj == "target",])

production = d[,c("gameid","context","nameClickedObj","alt1Name","alt2Name","refExp","clickedColor","clickedType")]
# correct for change in labelling (we realized what we considered pink was mostly considered purple)
production$clickedColor = ifelse(as.character(production$clickedColor) == 'pink', 'purple', as.character(production$clickedColor))
production$alt1Name = gsub("pink", "purple", production$alt1Name)
production$alt2Name = gsub("pink", "purple", production$alt2Name)

# get meantypicalities from previous study
typ = read.csv(file=here("data","raw","norming_exp2","typicality_exp2_type.csv"))
typ = typ[as.character(typ$Item) == as.character(typ$Utterance),]
row.names(typ) = paste(typ$Color,typ$Item)

production$NormedTypicality = typ[paste(production$clickedColor,production$clickedType),]$Typicality
production$binaryTypicality = as.factor(ifelse(production$NormedTypicality > .5, "typical", "atypical"))

# clean responses
production$CleanedResponse = gsub("(^| )([bB]ananna|[Bb]annna|[Bb]anna|[Bb]annana|[Bb]anan|[Bb]ananaa|ban|bana|banada|nana|bannan|babanana|B)($| )"," banana",as.character(production$refExp))
production$CleanedResponse = gsub("(^| )([Cc]arot|[Cc]arrrot|[Cc]arrott|car|carrpt|carrote|carr)($| )"," carrot",as.character(production$CleanedResponse))
production$CleanedResponse = gsub("(^| )([Pp]earr|pea)$"," pear",as.character(production$CleanedResponse))
production$CleanedResponse = gsub("(^| )([Tt]omaot|tokm|tmatoe|tamato|toato|tom|[Tt]omatoe|tomamt|tomtato|toamoat|mato|totomato|tomatop)($| )"," tomato",as.character(production$CleanedResponse))
production$CleanedResponse = gsub("(^| )([Aa]ppe|appple|APPLE|appl|app|apale|aple|ap)($| )"," apple",as.character(production$CleanedResponse))
production$CleanedResponse = gsub("(^| )([Pp]eper|pepp|peppre|pep|bell|jalapeno|jalpaeno|eppper|jalpaeno?)($| )"," pepper",as.character(production$CleanedResponse))
production$CleanedResponse = gsub("(^| )([Aa]vacado|avodado|avacdo|[Aa]vacadfo|avo|avacoda|avo|advocado|avavcado|avacodo|guacamole|gaucamole|guacolome|advacado|avacado,|avacado\\\\)($| )"," avocado",as.character(production$CleanedResponse))

# categorize responses
# color is mentioned
production$ColorMentioned = ifelse(grepl("green|purple|white|black|brown|purple|violet|yellow|gold|orange|prange|silver|blue|blu|pink|red|purlpe|pruple|puyrple|purplke|yllow|grean|dark|purp|yel|gree|gfeen|bllack|blakc|grey|neon|gray|blck|blu|blac|lavender|ornage|pinkish|^or ", production$refExp, ignore.case = TRUE), T, F)
# type is mentioned
production$ItemMentioned = ifelse(grepl("apple|banana|carrot|tomato|pear|pepper|avocado|jalpaeno?", production$CleanedResponse, ignore.case = TRUE), T, F)
# category is mentioned
production$CatMentioned = ifelse(grepl("fruit|fru7t|veg|veggi|veggie|vegetable", production$CleanedResponse, ignore.case = TRUE), T, F)
# negation is included
production$NegationMentioned = ifelse(grepl("not|isnt|arent|isn't|aren't|non", production$CleanedResponse, ignore.case = TRUE), T, F)
# more abstract color modifiers are used
production$ColorModifierMentioned = ifelse(grepl("normal|abnormal|healthy|dying|natural|regular|funky|rotten|noraml|norm", production$CleanedResponse, ignore.case = TRUE), T, F)
# descriptions are included
production$DescriptionMentioned = ifelse(grepl("like|round|sauce|long|rough|grass|doc|bunnies|bunny|same|stem|inside|ground|with|smile|monkey|sphere", production$CleanedResponse, ignore.case = TRUE), T, F)
# only differentiate between color, type and other
production$Other = ifelse(production$CatMentioned | production$NegationMentioned | production$ColorModifierMentioned | production$DescriptionMentioned, T, F)

# summarize utterance types
production$UtteranceType = as.factor(
  ifelse(production$ItemMentioned & production$ColorMentioned & !production$Other, "color_and_type", 
         ifelse(production$ColorMentioned & !production$ItemMentioned & !production$Other, "color", 
                ifelse(production$ItemMentioned & !production$ColorMentioned & !production$Other, "type", 
                       "OTHER"))))

production$Color = ifelse(production$UtteranceType == "color",1,0)
production$ColorAndType = ifelse(production$UtteranceType == "color_and_type",1,0)
production$Type = ifelse(production$UtteranceType == "type",1,0)
# we don't specify 'other' here again because utterances that are not Cat,Neg,ColorMod,Description are "Hi" or "Hello" or clarification questions such as "do you know if i can just tell u what the picture is or do i have to tell u it's color?" and therefore uninterpretable
# those are 6 utterances (they are still though in UtteranceType == "OTHER")
# production$Other = ifelse(production$UtteranceType == "OTHER",1,0)
production$Item = production$clickedType

# 2.6.1 Prepare data frame for visualization
# add correct distractor names
dists = read.csv(here("analysis","helper_scripts","distractors_exp2.csv"))
row.names(dists) = dists$target

production$dDist1 = grepl("distractor_",production$alt1Name)
production$dDist2 = grepl("distractor_",production$alt2Name)
production$Dist1 = as.character(production$alt1Name)
production$Dist2 = as.character(production$alt2Name)
production$Dist1 = ifelse(production$dDist1, as.character(dists[production$nameClickedObj,]$distractor), production$Dist1)
production$Dist2 = ifelse(production$dDist2, as.character(dists[production$nameClickedObj,]$distractor), production$Dist2)

production$Dist1Color = sapply(strsplit(as.character(production$Dist1),"_"), "[", 2)
production$Dist1Type = sapply(strsplit(as.character(production$Dist1),"_"), "[", 1)
production$Dist2Color = sapply(strsplit(as.character(production$Dist2),"_"), "[", 2)
production$Dist2Type = sapply(strsplit(as.character(production$Dist2),"_"), "[", 1)

production$Dist1_rev = paste(production$Dist1Color, production$Dist1Type, sep="_")
production$Dist2_rev = paste(production$Dist2Color, production$Dist2Type, sep="_")

# 3 BDA 
# 3.1 BDA data preparation
# create utterances for bda
production$UttforBDA = "other"
production[production$Color == 1,]$UttforBDA = as.character(production[production$Color == 1,]$clickedColor)
production[production$Type == 1,]$UttforBDA = as.character(production[production$Type == 1,]$clickedType)
production[production$ColorAndType == 1,]$UttforBDA = paste(as.character(production[production$ColorAndType == 1,]$clickedColor),as.character(production[production$ColorAndType == 1,]$clickedType),sep="_")

production$target = paste(production$clickedColor, production$clickedType, sep="_")

production$Informative = as.factor(ifelse(production$context %in% c("informative","informative-cc"),"informative","overinformative"))
production$CC = as.factor(ifelse(production$context %in% c("informative-cc","overinformative-cc"),"cc","no-cc"))

# create csv file with results
production$condition = production$context
agr = production %>%
  select(Color,Type,ColorAndType,Other,NormedTypicality,condition,target) %>%
  gather(uttType,Mentioned,-condition,-NormedTypicality,-target) %>%
  group_by(uttType,condition,NormedTypicality,target) %>%
  summarise(empiricProb=mean(Mentioned),ci.low=ci.low(Mentioned),ci.high=ci.high(Mentioned))
agr = as.data.frame(agr)

levels(agr$condition) = c("informative","informative-cc", "overinformative", "overinformative-cc")
agr$uttType = ifelse(agr$uttType == "Color", "colorOnly", ifelse(agr$uttType == "Type", "typeOnly", ifelse(agr$uttType == "ColorAndType", "colorType","other")))

# write.csv(agr,file='rscripts/app/data/empiricalReferenceProbs.csv', row.names = FALSE)

# write unique conditions for bda
p_no_other = droplevels(production[production$UttforBDA != "other",])
# nrow(p_no_other)

p_no_other$DistractorCombo = as.factor(ifelse(as.character(p_no_other$Dist1) < as.character(p_no_other$Dist2), paste(p_no_other$Dist1, p_no_other$Dist2), paste(p_no_other$Dist2, p_no_other$Dist1)))

# nrow(unique(p_no_other[,c("nameClickedObj","DistractorCombo")]))
p_no_other$BDADist1 = sapply(strsplit(as.character(p_no_other$DistractorCombo)," "), "[", 1)
p_no_other$BDADist2 = sapply(strsplit(as.character(p_no_other$DistractorCombo)," "), "[", 2)
p_no_other$BDADist1Color = sapply(strsplit(as.character(p_no_other$BDADist1),"_"), "[", 2)
p_no_other$BDADist1Type = sapply(strsplit(as.character(p_no_other$BDADist1),"_"), "[", 1)
p_no_other$BDADist2Color = sapply(strsplit(as.character(p_no_other$BDADist2),"_"), "[", 2)
p_no_other$BDADist2Type = sapply(strsplit(as.character(p_no_other$BDADist2),"_"), "[", 1)


write.table(unique(p_no_other[,c("context","clickedColor","clickedType","BDADist1Color","BDADist1Type","BDADist2Color","BDADist2Type")]),file=here("models","bdaInput","typicality","unique_conditions.csv"),sep=",",col.names=F,row.names=F,quote=F)

# write data for bda
write.table(p_no_other[,c("context","clickedColor","clickedType","BDADist1Color","BDADist1Type","BDADist2Color","BDADist2Type","UttforBDA")],file=here("models","bdaInput","typicality","bda_data.csv"),sep=",",col.names=F,row.names=F,quote=F)
