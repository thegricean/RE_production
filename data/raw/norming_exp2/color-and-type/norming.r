library(dplyr)
library(ggplot2)
library(bootstrap)
library(lme4)
library(tidyr)
library(here)

theme_set(theme_bw(18))
source(here("analysis","helper_scripts","helpers.r"))

d0 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming0.csv"),sep=",",header=T)
d1 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming1.csv"),sep=",",header=T)
d1$workerid = d1$workerid + 20
d2 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming2.csv"),sep=",",header=T)
d2$workerid = d2$workerid + 20 + 10
d3 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming3.csv"),sep=",",header=T)
d3$workerid = d3$workerid + 20 + 10 + 9
d4 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming4.csv"),sep=",",header=T)
d4$workerid = d4$workerid + 20 + 10 + 9 + 9
d5 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming5.csv"),sep=",",header=T)
d5$workerid = d5$workerid + 20 + 10 + 9 + 9 + 9
d6 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming6.csv"),sep=",",header=T)
d6$workerid = d6$workerid + 20 + 10 + 9 + 9 + 9 + 9
d7 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming7.csv"),sep=",",header=T)
d7$workerid = d7$workerid + 20 + 10 + 9 + 9 + 9 + 9 + 9
d8 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming8.csv"),sep=",",header=T)
d8$workerid = d8$workerid + 20 + 10 + 9 + 9 + 9 + 9 + 9 + 9
d9 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming9.csv"),sep=",",header=T)
d9$workerid = d9$workerid + 20 + 10 + 9 + 9 + 9 + 9 + 9 + 9 + 9
d10 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming10.csv"),sep=",",header=T)
d10$workerid = d10$workerid + 20 + 10 + 9 + 9 + 9 + 9 + 9 + 9 + 9 + 9
d11 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming11.csv"),sep=",",header=T)
d11$workerid = d11$workerid + 20 + 10 + 9 + 9 + 9 + 9 + 9 + 9 + 9 + 9 + 9
d12 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming12.csv"),sep=",",header=T)
d12$workerid = d12$workerid + 20 + 10 + 9 + 9 + 9 + 9 + 9 + 9 + 9 + 9 + 9 + 9
d13 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming13.csv"),sep=",",header=T)
d13$workerid = d13$workerid + 129
d14 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming14.csv"),sep=",",header=T)
d14$workerid = d14$workerid + 129 + 9
d15 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming15.csv"),sep=",",header=T)
d15$workerid = d15$workerid + 129 + 9 + 9
d16 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming16.csv"),sep=",",header=T)
d16$workerid = d16$workerid + 129 + 9 + 9 + 9
d17 = read.table(file=here("data","raw","norming_exp2","color-and-type","norming17.csv"),sep=",",header=T)
d17$workerid = d17$workerid + 129 + 9 + 9 + 9 + 9

# alltogether 173 participants
d = rbind(d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17)


totalnrow = nrow(d)
d$Trial = d$slide_number_in_experiment - 1
length(unique(d$workerid))
d$Item = sapply(strsplit(as.character(d$object),"_"), "[", 1)
d$Color = sapply(strsplit(as.character(d$object),"_"), "[", 2)
d$utterance = gsub("^ ","",as.character(d$utterance))
# look at turker comments
unique(d[,c("workerid","comments")])
d$UttColor = sapply(strsplit(as.character(d$utterance)," "), "[", 1)
d$UttType = sapply(strsplit(as.character(d$utterance)," "), "[", 2)
d$Utterance = paste(d$UttColor,d$UttType,sep="_")
d$InvUtterance = paste(d$UttType,d$UttColor,sep="_")
d$Third = ifelse(d$Trial < 110/3, 1, ifelse(d$Trial < 2*(110/3),2,3))

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
table(d$age)

ggplot(d, aes(education)) +
  stat_count()

ggplot(d, aes(language)) +
  stat_count()

ggplot(d, aes(enjoyment)) +
  stat_count()

ggplot(d, aes(Item)) +
  stat_count()

ggplot(d, aes(Color)) +
  stat_count()

# sanity check
d[d$object == d$InvUtterance & d$response < .6,c("workerid","Third","object","utterance","response")]
table(d[d$object == d$InvUtterance & d$response < .6,]$Third)

# exclude non-native speakers
unique(d$language)
d = droplevels(d[!d$language == "Chinese",])
d = droplevels(d[!d$language == "Urdu/English",])
d = droplevels(d[!d$language == "Italian",])
length(unique(d$workerid))

# exclude people who didn't systematically give higher ratings for "true" cases (excluded 11 cases where mean(match) - mean(no_match) < .35)
d$Match = ifelse(d$object == d$InvUtterance, "match","no_match")
means = d %>%
  group_by(workerid,Match) %>%
  summarise(mean=mean(response))
tmp = means %>%
  group_by(workerid) %>%
  summarise(diff=mean[1]-mean[2])
tmp = as.data.frame(tmp)
tmp = tmp[order(tmp[,c("diff")]),]
head(tmp,10)
problematic = tmp[tmp$diff < .35,]$workerid
problematic

d = droplevels(d[!d$workerid %in% problematic,]) 
length(unique(d$workerid)) # 160 participants left

# exclude pink
df = droplevels(d[!(d$UttColor == 'pink'),])
# replace internal object name "pink" by "purple" (since we misinterpreted the color)
df$Color = ifelse(df$Color == 'pink', 'purple', df$Color)
df$object = paste(df$Item,df$Color,sep="_")

items = as.data.frame(table(d$Utterance,d$object))
nrow(items)
colnames(items) = c("Utterance","Object","Freq")
items = items[order(items[,c("Freq")]),]
ggplot(items, aes(x=Freq)) +
  geom_histogram()
table(items$Freq)

# z-score ratings
zscored = df %>%
  group_by(workerid) %>%
  summarise(Range=max(response) - min(response))
zscored = as.data.frame(zscored)
row.names(zscored) = as.character(zscored$workerid)
ggplot(zscored,aes(x=Range)) +
  geom_histogram()

df$Range = zscored[as.character(df$workerid),]$Range
df$zresponse = df$response / df$Range

agr = df %>% 
  group_by(Item,Color,Utterance) %>%
  summarise(MeanTypicality = mean(response), ci.low=ci.low(response),ci.high=ci.high(response),MeanZTypicality = mean(zresponse), ci.low.z=ci.low(zresponse),ci.high.z=ci.high(zresponse))
agr = as.data.frame(agr)
agr$YMin = agr$MeanTypicality - agr$ci.low
agr$YMax = agr$MeanTypicality + agr$ci.high
agr$YMinZ = agr$MeanZTypicality - agr$ci.low.z
agr$YMaxZ = agr$MeanZTypicality + agr$ci.high.z

agr$Combo = paste(agr$Color,agr$Item,sep=" ")
agr$Color = as.factor(as.character(agr$Color))
agr$Utterance = gsub("_"," ",agr$Utterance)

ggplot(agr, aes(x=Combo,y=MeanTypicality,color=Color)) +
  geom_point(size=4) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25) +
  ylab("Typicality") +
  xlab("Objects") +
  facet_wrap(~Utterance,scales="free_x",nrow=8) +
  scale_color_manual(values=levels(agr$Color)) +
  theme(axis.title=element_text(size=55)) +
  theme(axis.text.x = element_text(angle=45,size=35,vjust=1,hjust=1)) +
  theme(axis.text.y=element_text(size=30)) +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 60, b = 0, l = 0))) +
  theme(axis.ticks=element_line(size=.25), axis.ticks.length=unit(.75,"mm")) +
  theme(strip.text.x=element_text(size=50)) +
  theme(legend.position="none") +
  theme(strip.background=element_rect(colour="#939393",fill="lightgrey")) +
  theme(panel.background=element_rect(colour="#939393"))
# ggsave("../../../../../../Uni/BachelorThesis/graphs/typicalities_adjnounobj.png",height=49, width=40)

ggplot(agr, aes(x=Combo,y=MeanZTypicality,color=Color)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMinZ,ymax=YMaxZ),width=.25) +
  xlab("Object") +
  facet_wrap(~Utterance,scales="free_x",nrow=4) +
  scale_color_manual(values=levels(agr$Color)) +
  theme(axis.text.x = element_text(angle=45,size=5,vjust=1,hjust=1))
# ggsave("graphs/ztypicalities.png",height=20, width=35)

ggplot(agr, aes(x=MeanTypicality,y=MeanZTypicality)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMinZ,ymax=YMaxZ),width=.025,alpha=.5) +
  geom_errorbarh(aes(xmin=YMin,xmax=YMax),height=.025,alpha=.5) +
  geom_abline(intercept=0,slope=1,linetype="dashed", color="gray40")
# ggsave("graphs/scale_unscaled_correlation.png",height=4, width=6)

ggplot(df, aes(x=response,fill=Match)) +
  geom_histogram() +
  facet_wrap(~workerid)
# ggsave("graphs/subject_variability.png",height=20, width=20)

# create uniform typicality csv file
agr$CI.low = agr$YMin
agr$CI.high = agr$YMax
agr$Typicality = round(agr$MeanTypicality, digits=3)

write.csv(agr[,c("Item","Color","Utterance","Typicality","CI.low","CI.high")], file=here("data","raw","norming_exp2","typicality_exp2_color-and-type.csv"),row.names=F,quote=F)