library(tidyverse)
library(here)

source(here("analysis","helper_scripts","helpers.R"))

# Read raw data
d = read.table(file=here("data","raw","production_exp2","rawdata_exp2.csv"),sep="\t", header=T, quote="")
nrow(d)
head(d)
# unique(d$gameid): 65 pairs

# Exclude data and participants that cannot be used for analysis
# Exclude NA referential expressions 
d = droplevels(d[!(is.na(d$refExp)),])
# Exclude pairs because listeners didn't respond
d = droplevels(d[!(d$gameid == "0960-e" | d$gameid == "6911-b" | d$gameid == "1866-f" | d$gameid == "6581-5"), ])
# Exclude participants that were not paid because they didn't finish it
d = droplevels(d[!(d$gameid == "6444-b" | d$gameid == "4924-4"), ])
# Exclude tabu players
d = droplevels(d[!(d$gameid == "1544-1" | d$gameid == "4885-8" | d$gameid == "8360-7" | d$gameid == "4624-5" | d$gameid == "5738-a" | d$gameid == "8931-5" | d$gameid == "8116-a" | d$gameid == "6180-c" | d$gameid == "1638-6" | d$gameid == "6836-b"), ])
# unique(d$gameid): 47 pairs
# Exclude trials with distractor choices
d = droplevels(d[d$targetStatusClickedObj == "target",])

# Exclude unnecessary columns
production = d[,c("gameid","context","nameClickedObj","alt1Name","alt2Name","refExp","clickedColor","clickedType")]

# Correct for change in labelling (we realized what we considered pink was mostly considered purple)
production$clickedColor = ifelse(as.character(production$clickedColor) == 'pink', 'purple', as.character(production$clickedColor))
production$nameClickedObj = gsub("pink", "purple", production$nameClickedObj)
production$alt1Name = gsub("pink", "purple", production$alt1Name)
production$alt2Name = gsub("pink", "purple", production$alt2Name)

# Get typicalities from typicality "type" study
typ = read.csv(file=here("data","raw","norming_exp2","typicality_exp2_type.csv"))
typ = typ[as.character(typ$Item) == as.character(typ$Utterance),]
row.names(typ) = paste(typ$Color,typ$Item)

production$NormedTypicality = typ[paste(production$clickedColor,production$clickedType),]$Typicality
# production$binaryTypicality = as.factor(ifelse(production$NormedTypicality > .5, "typical", "atypical"))

# Clean responses to make them easier to categorize
production$CleanedResponse = gsub("(^| )([bB]ananna|[Bb]annna|[Bb]anna|[Bb]annana|[Bb]anan|[Bb]ananaa|ban|bana|banada|nana|bannan|babanana|B)($| )"," banana",as.character(production$refExp))
production$CleanedResponse = gsub("(^| )([Cc]arot|[Cc]arrrot|[Cc]arrott|car|carrpt|carrote|carr)($| )"," carrot",as.character(production$CleanedResponse))
production$CleanedResponse = gsub("(^| )([Pp]earr|pea)$"," pear",as.character(production$CleanedResponse))
production$CleanedResponse = gsub("(^| )([Tt]omaot|tokm|tmatoe|tamato|toato|tom|[Tt]omatoe|tomamt|tomtato|toamoat|mato|totomato|tomatop)($| )"," tomato",as.character(production$CleanedResponse))
production$CleanedResponse = gsub("(^| )([Aa]ppe|appple|APPLE|appl|app|apale|aple|ap)($| )"," apple",as.character(production$CleanedResponse))
production$CleanedResponse = gsub("(^| )([Pp]eper|pepp|peppre|pep|bell|jalapeno|jalpaeno|eppper|jalpaeno?)($| )"," pepper",as.character(production$CleanedResponse))
production$CleanedResponse = gsub("(^| )([Aa]vacado|gauc|avodado|avacdo|[Aa]vacadfo|avo|avacoda|avo|advocado|avavcado|avacodo|guacamole|gaucamole|guacolome|advacado|avacado,|avacado\\\\)($| )"," avocado",as.character(production$CleanedResponse))

# Categorize responses
# Was a color mentioned?
# we also include here "lighter", "dark", "brighter"
production$ColorMentioned = ifelse(grepl("green|purple|white|black|brown|purple|violet|yellow|gold|orange|prange|silver|blue|blu|pink|red|purlpe|pruple|puyrple|purplke|yllow|grean|dark|purp|yel|gree|gfeen|bllack|blakc|grey|neon|gray|blck|blu|blac|lavender|ornage|pinkish|lighter|brighter|re$|^or ", production$refExp, ignore.case = TRUE), T, F)

# Was a type mentioned?
production$ItemMentioned = ifelse(grepl("apple|banana|carrot|tomato|pear|pepper|avocado|jalpaeno?", production$CleanedResponse, ignore.case = TRUE), T, F)

# Was a cetegory mentioned? (later in "other")
production$CatMentioned = ifelse(grepl("fruit|fru7t|veg|veggi|veggie|vegetable", production$CleanedResponse, ignore.case = TRUE), T, F)
# Was a negation included? (later in "other")
production$NegationMentioned = ifelse(grepl("not|isnt|arent|isn't|aren't|non", production$CleanedResponse, ignore.case = TRUE), T, F)
# Were more abstract color modifiers used? (later in "other")
production$ColorModifierMentioned = ifelse(grepl("normal|abnormal|healthy|dying|natural|regular|funky|rotten|noraml|norm", production$CleanedResponse, ignore.case = TRUE), T, F)
# Were descriptions included? (later in "other")
production$DescriptionMentioned = ifelse(grepl("like|round|sauce|long|rough|grass|doc|bunnies|bunny|same|stem|inside|ground|with|smile|monkey|sphere|board", production$CleanedResponse, ignore.case = TRUE), T, F)

# Only differentiate between color mention, type mention and expressions including other utterances
production$Other = ifelse(production$CatMentioned | production$NegationMentioned | production$ColorModifierMentioned | production$DescriptionMentioned, T, F)

# Summarize utterance types
production$UtteranceType = as.factor(
  ifelse(production$ItemMentioned & production$ColorMentioned & !production$Other, "color_and_type", 
         ifelse(production$ColorMentioned & !production$ItemMentioned & !production$Other, "color", 
                ifelse(production$ItemMentioned & !production$ColorMentioned & !production$Other, "type", 
                       "OTHER"))))

production$Color = ifelse(production$UtteranceType == "color",1,0)
production$ColorAndType = ifelse(production$UtteranceType == "color_and_type",1,0)
production$Type = ifelse(production$UtteranceType == "type",1,0)

# Add correct distractor names
# Read lexicon which decodes the type of a color competitor for a certain target
dists = read.csv(here("analysis","helper_scripts","distractors_exp2.csv"))
row.names(dists) = dists$target

# Was there a color competitor in distractor one or two? 
production$dDist1 = grepl("distractor_",production$alt1Name)
production$dDist2 = grepl("distractor_",production$alt2Name)
# If so, replace it by the distractor object found in the lexicon
production$Dist1 = as.character(production$alt1Name)
production$Dist2 = as.character(production$alt2Name)
production$Dist1 = ifelse(production$dDist1, as.character(dists[production$nameClickedObj,]$distractor), production$Dist1)
production$Dist2 = ifelse(production$dDist2, as.character(dists[production$nameClickedObj,]$distractor), production$Dist2)

# Make distractor's color and type easily accessible
production$Dist1Color = sapply(strsplit(as.character(production$Dist1),"_"), "[", 2)
production$Dist1Type = sapply(strsplit(as.character(production$Dist1),"_"), "[", 1)
production$Dist2Color = sapply(strsplit(as.character(production$Dist2),"_"), "[", 2)
production$Dist2Type = sapply(strsplit(as.character(production$Dist2),"_"), "[", 1)


# BDA data preparation

# Create utterances for bda
production$UttforBDA = "other"
production[production$Color == 1,]$UttforBDA = as.character(production[production$Color == 1,]$clickedColor)
production[production$Type == 1,]$UttforBDA = as.character(production[production$Type == 1,]$clickedType)
production[production$ColorAndType == 1,]$UttforBDA = paste(as.character(production[production$ColorAndType == 1,]$clickedColor),as.character(production[production$ColorAndType == 1,]$clickedType),sep="_")

production$Target = paste(production$clickedColor, production$clickedType, sep="_")

# Write unique conditions for bda
bda_df = droplevels(production[production$UttforBDA != "other",])

# Distractors are sorted alphabetically to detect identical contexts for unique_conditions
bda_df$DistractorCombo = as.factor(ifelse(as.character(bda_df$Dist1) < as.character(bda_df$Dist2), paste(bda_df$Dist1, bda_df$Dist2), paste(bda_df$Dist2, bda_df$Dist1)))

bda_df$BDADist1 = sapply(strsplit(as.character(bda_df$DistractorCombo)," "), "[", 1)
bda_df$BDADist2 = sapply(strsplit(as.character(bda_df$DistractorCombo)," "), "[", 2)
bda_df$d1_color = sapply(strsplit(as.character(bda_df$BDADist1),"_"), "[", 2)
bda_df$d1_item = sapply(strsplit(as.character(bda_df$BDADist1),"_"), "[", 1)
bda_df$d2_color = sapply(strsplit(as.character(bda_df$BDADist2),"_"), "[", 2)
bda_df$d2_item = sapply(strsplit(as.character(bda_df$BDADist2),"_"), "[", 1)

bda_df <- bda_df %>% 
  rename(t_color = clickedColor,
         t_item = clickedType,
         response = UttforBDA,
         condition = context)

# Write Bayesian data analysis files (data and unique conditions)
write.table(unique(bda_df[,c("condition","t_color","t_item","d1_color","d1_item","d2_color","d2_item")]),file=here("models","bdaInput","typicality","unique_conditions.csv"),sep=",",row.names=F,quote=F)
write.table(bda_df[,c("condition","t_color","t_item","d1_color","d1_item","d2_color","d2_item","response")],file=here("models","bdaInput","typicality","bda_data.csv"),sep=",",row.names=F,quote=F)

# Construct meanings json for BDA
typicality_data = read.table(file=here("data","typicality_exp2.csv"),sep=",", header=T) %>%
  unite(object, Color, Item) %>%
  mutate(utterance = ifelse(UtteranceType =='color-and-type', 
                            str_replace(Utterance," ","_"),
                            as.character(Utterance))) %>%
  rename(typicality = Typicality) %>%
  rowwise() %>%
  mutate(output = paste0('\"', object, '\" : ', typicality)) %>%
  group_by(utterance) %>%
  summarize(output = paste(output, collapse = ",\n     ")) %>%
  mutate(output = paste0('{\n     ', output, '}')) %>%
  summarize(output = paste0('\"', utterance, '\" : ', output, collapse = ',\n  ')) %>%
  mutate(output = paste0('{\n  ', output, '}'))

write_file(typicality_data$output,
           path=here("models","refModule","json","typicality-meanings.json"))

# Write file for regression analysis and visualization
production$Dist1 = paste(production$Dist1Color, production$Dist1Type, sep="_")
production$Dist2 = paste(production$Dist2Color, production$Dist2Type, sep="_")
production$Item = production$clickedType
production$TargetColor = production$clickedColor
preproc_file = production[,c("gameid","context","NormedTypicality","UtteranceType","Color","ColorAndType","Type","ColorMentioned","ItemMentioned","Other","Item","TargetColor","Target","Dist1","Dist2","refExp","UttforBDA")]
write.table(preproc_file,file=here("data","data_exp2.csv"),sep="\t",row.names=F,quote=F)