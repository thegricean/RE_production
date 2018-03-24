theme_set(theme_bw(18))
library(tidyverse)
library(scales)
source("../../../../analysis/helper_scripts/helpers.R")

d = read.table(file="norming.csv",sep=",", header=T, quote="")
head(d)
nrow(d)
summary(d)
totalnrow = nrow(d)
d$Trial = d$slide_number_in_experiment - 1
d$Half = as.factor(ifelse(d$Trial < 19, "first","second"))
length(unique(d$workerid))

# look at turker comments
unique(d$comments)

ggplot(d, aes(rt)) +
  geom_histogram() +
  scale_x_continuous(limits=c(0,10000))

ggplot(d, aes(log(rt))) +
  geom_histogram() 

summary(d$Answer.time_in_minutes)
ggplot(d, aes(Answer.time_in_minutes)) +
  geom_histogram()

ggplot(d, aes(gender)) +
  stat_count()

ggplot(d, aes(asses)) +
  stat_count()

ggplot(d, aes(age)) +
  geom_histogram()

ggplot(d, aes(education)) +
  stat_count()

ggplot(d, aes(language)) +
  stat_count()

ggplot(d, aes(enjoyment)) +
  stat_count()

d$Combo = paste(d$item,d$color,d$condition)
sort(table(d$Combo))
  
agr = d %>% 
  group_by(item,color,condition) %>%
  summarise(meanresponse = mean(response), ci.low=ci.low(response),ci.high=ci.high(response))
agr = as.data.frame(agr)
agr$YMin = agr$meanresponse - agr$ci.low
agr$YMax = agr$meanresponse + agr$ci.high

ggplot(agr, aes(x=color,y=meanresponse,color=condition)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25) +
  facet_wrap(~item,scales="free_x")

# figure out which cases have overlapping error bars in modified and unmodified condition -- wow, these turn out to be exactly the four cases with the biggest difference that i was plotting anyway (green chair, pink golfball, red stapler, pink weddingcake)
overlap = agr %>%
  group_by(item,color) %>%
  summarise(NonOverlappingMeans = (YMin[1] >= YMax[2] | YMax[1] <= YMin[2]))
overlap = as.data.frame(overlap)
overlap[overlap$NonOverlappingMeans,]

mutated = agr %>%
  mutate(Item=item,Color=color,Modification=condition,Typicality=meanresponse,CI.low=YMin,CI.high=YMax)

write.table(mutated[,c("Item","Color","Modification","Typicality","CI.low","CI.high")],file="../../../typicality_exp1_objecttypicality.csv",sep="\t",row.names=F,col.names=T,quote=F)

# compare the "how typical is this color for an X" wording to the current "how typical is this for an X" wording
typicalities = read.table("../../../typicality_exp1_colortypicality.csv",header=T)
head(typicalities)
head(mutated)
#row.names(typicalities) = paste(typicalities$Item,typicalities$Color)
typicalities$Modification = "puretypicality"

m = merge(mutated,typicalities,all=T) %>%
  select(Item,Color,Modification,Typicality,CI.low,CI.high)
summary(m)

ggplot(m, aes(x=Color,y=Typicality,color=Modification)) +
  geom_point() +
  geom_errorbar(aes(ymin=CI.low,ymax=CI.high),width=.25) +
  facet_wrap(~Item,scales="free_x")
ggsave("typicalities_full.pdf",height=10)

# force all values to be between .5 and 1
m$rescaledTypicality = rescale(m$Typicality,to=c(.5,1))
m$Utterance = paste(m$Color,m$Item,sep="_")
m[m$Modification != "modified",]$Utterance = as.character(m[m$Modification != "modified",]$Item)
head(m)
m$Object = paste(m$Color,m$Item,sep="_")

# FIXME the commented stuff is most likely deprecated
# write the three different typicality measures to file so they can be used by model
# write.table(m[m$Modification == "modified",c("Item","Color","rescaledTypicality")],file="typicalities_modified.txt",sep="\t",row.names=F,col.names=T,quote=F)
# 
# write.table(m[m$Modification == "unmodified",c("Item","Color","rescaledTypicality")],file="typicalities_unmodified.txt",sep="\t",row.names=F,col.names=T,quote=F)
# 
# write.table(m[m$Modification == "puretypicality",c("Item","Color","rescaledTypicality")],file="typicalities_pure.txt",sep="\t",row.names=F,col.names=T,quote=F)
# 

# get final values for model, 
# write.csv(m[m$Modification != "puretypicality",c("Object","rescaledTypicality","Utterance")],file="typicalities.csv",row.names=F,quote=F)
# write.csv(m[m$Modification != "puretypicality",c("Object","Typicality","Utterance")],file="typicalities_raw.csv",row.names=F,quote=F)
# write.csv(m[m$Modification != "puretypicality",c("Object","Typicality","Utterance","Modification","CI.low","CI.high")],file="typicalities_raw_withci.csv",row.names=F,quote=F)


# figure out which cases have the greatest typicality difference between modified and unmodified versions
diffs = m %>%
  filter(Modification != "puretypicality") %>%
  group_by(Item, Color) %>%
  summarise(Diff=Typicality[1]-Typicality[2],TypicalityModified=Typicality[1],TypicalityUnmodified=Typicality[2])
diffs = as.data.frame(diffs)
row.names(diffs) = paste(diffs$Color,diffs$Item)
# cases where modified version much more typical than unmodified version:
head(diffs[order(diffs[,c("Diff")],decreasing=T),])
maxdiffitems = as.character(diffs[order(diffs[,c("Diff")],decreasing=T),]$Item)[1:4]
write.csv(diffs[order(diffs[,c("Diff")],decreasing=T),],file="maxdiffitems.csv",row.names=F,quote=F)
m[m$Item %in% maxdiffitems,]
# cases where unmodified version more typical than modified version:
tail(diffs[order(diffs[,c("Diff")],decreasing=T),])


