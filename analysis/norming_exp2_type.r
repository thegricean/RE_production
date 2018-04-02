library(dplyr)
library(ggplot2)
library(bootstrap)
library(lme4)
library(tidyr)
library(here)

theme_set(theme_bw(18))
source(here("analysis","helper_scripts","helpers.r"))

d = read.table(file=here("data","raw","norming_exp2","original_type","norming_1.csv"),sep=",", header=T)#, quote="")
d1 = read.table(file=here("data","raw","norming_exp2","original_type","norming_2.csv"),sep=",", header=T)#, quote="")

d1$workerid = d1$workerid + 60
d = rbind(d,d1)
summary(d)

totalnrow = nrow(d)
d$Trial = d$slide_number_in_experiment - 1
length(unique(d$workerid))
d$Item = sapply(strsplit(as.character(d$object),"_"), "[", 1)
d$Color = sapply(strsplit(as.character(d$object),"_"), "[", 2)
# look at turker comments
unique(d[,c("workerid","comments")])

# exclude one worker who self-reportedly did the hit wrong
d = d[d$workerid != 16,]

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

##

ggplot(d, aes(x=response,fill=Color)) +
  geom_histogram(position="dodge") +
  geom_density(alpha=.4,color="gray80") +
  facet_wrap(~Item,nrow=2,scales="free")
# ggsave("graphs/typicalities_histograms.pdf",height=5,width=10)

nocups = d[grep("cup",d$object,invert=T),]
nocups = nocups[grep("purple",nocups$object,invert=T),]
nocups = nocups[grep("cup",nocups$utterance,invert=T),]
nocups = nocups[grep("fruit",nocups$utterance,invert=T),]
nocups = nocups[grep("vegetable",nocups$utterance,invert=T),]
nocups = droplevels(nocups)

df = nocups
df$Color = ifelse(df$Color == 'pink', 'purple', df$Color)

agr = df %>% 
  group_by(Item,Color,utterance) %>%
  summarise(MeanTypicality = mean(response), ci.low=ci.low(response),ci.high=ci.high(response))
agr = as.data.frame(agr)
agr$YMin = agr$MeanTypicality - agr$ci.low
agr$YMax = agr$MeanTypicality + agr$ci.high

agr$Combo = paste(agr$Color,agr$Item)
agr$Color = as.factor(as.character(agr$Color))
ggplot(agr, aes(x=Combo,y=MeanTypicality,color=Color)) +
  geom_point(size=2) +
  ylab("Typicality") +
  xlab("Objects") +
  theme(legend.position="none") +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25) +
  facet_wrap(~utterance,scales="free_x",nrow=4) +
  scale_color_manual(values=levels(agr$Color)) +
  theme(axis.title=element_text(size=25)) +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 60, b = 0, l = 0))) +
  theme(axis.text.x = element_text(angle=45,size=20,vjust=1,hjust=1)) +
  theme(axis.text.y=element_text(size=10)) +
  theme(axis.ticks=element_line(size=.25), axis.ticks.length=unit(.75,"mm")) +
  theme(strip.text.x=element_text(size=25)) +
  theme(strip.background=element_rect(colour="#939393",fill="lightgrey")) +
  theme(panel.background=element_rect(colour="#939393")) 
# ggsave("graphs/typicalities.png",height=15, width=17)

# create uniform typicality csv file
agr$Typicality = round(agr$MeanTypicality, digits = 3)
agr$Utterance = agr$utterance
agr$CI.low = agr$YMin
agr$CI.high = agr$YMax

write.csv(agr[,c("Item","Color","Utterance","Typicality","CI.low","CI.high")], file=here("data","typicality_exp2_type.csv"),row.names=F,quote=F)
