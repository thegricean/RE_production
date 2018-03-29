theme_set(theme_bw(18))
source("../../../analysis/helper_scripts/helpers.R")

d = read.table(file="norming.csv",sep=",", header=T, quote="")
head(d)
nrow(d)
summary(d)
totalnrow = nrow(d)
d$itemtype = as.character(d$itemtype)
d[d$itemtype == "dist_super",]$itemtype = "dist_diffsuper"
d$itemtype = as.factor(as.character(d$itemtype))
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
  geom_histogram(stat="count")

ggplot(d, aes(asses)) +
  geom_histogram(stat="count")

ggplot(d, aes(age)) +
  geom_histogram()

ggplot(d, aes(education)) +
  geom_histogram(stat="count")

ggplot(d, aes(language)) +
  geom_histogram(stat="count")

ggplot(d, aes(enjoyment)) +
  geom_histogram(stat="count")

# numbers to report in paper:
un = unique(d[,c("labeltype","itemtype","label","item")])
nrow(un)
table(un$itemtype)
table(d$workerid,d$itemtype)

d$Combo = paste(d$item,d$label)
sort(table(d$Combo)) # how many of each? is it roughly evenly distributed?

# plot item means shown in appendix
agr = d %>% 
  mutate(itemtype=fct_recode(itemtype,"same-category\ndistractor"="dist_samesuper","different-category\ndistractor"="dist_diffsuper"),
         Utterance=fct_recode(labeltype,"sub\n(\'dalmatian')"="sub","basic\n('dog')"="basic","super\n('animal')"="super")) %>%
  mutate(itemtype=fct_relevel(itemtype,"target"),Utterance=fct_relevel(Utterance,"sub\n('dalmatian')")) %>%
  group_by(itemtype,Utterance) %>%
  summarise(meanresponse = mean(response), ci.low=ci.low(response),ci.high=ci.high(response))

ggplot(agr, aes(x=Utterance,y=meanresponse)) +
  geom_bar(stat="identity",color="black",fill="gray80") +
  geom_errorbar(aes(ymin=meanresponse-ci.low,ymax=meanresponse+ci.high),width=.25) +
  ylab("Mean typicality rating") +
  facet_wrap(~itemtype)
ggsave("../../../writing/pics/exp3typicalityratings.pdf",width=10)

# plot all items
agr = d %>% 
  group_by(itemtype,labeltype,item) %>%
  summarise(meanresponse = mean(response), ci.low=ci.low(response),ci.high=ci.high(response))
agr = as.data.frame(agr)
agr$YMin = agr$meanresponse-agr$ci.low
agr$YMax = agr$meanresponse+agr$ci.high
agr$Utterance = factor(x=as.character(agr$labeltype),levels=c("sub","basic","super"))

ggplot(agr,aes(x=Utterance,y=meanresponse,color=itemtype)) +
  geom_point() +
  geom_errorbar(aes(ymin=meanresponse-ci.low,ymax=meanresponse+ci.high),width=.25) +
  facet_wrap(~item)

tmp = agr
agr = agr[order(agr[,c("Utterance")]),]
agr$Label = factor(x=as.character(agr$label),levels=unique(as.character(agr$label)))
ggplot(agr, aes(x=item,y=meanresponse,color=itemtype)) +
  geom_point() +
  geom_errorbar(aes(ymin=meanresponse-ci.low,ymax=meanresponse+ci.high),width=.25) +
  facet_wrap(~Label,scales="free_x") +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1,size=8))

# write data
write.csv(agr[,c("itemtype","labeltype","item","label","meanresponse","YMin","YMax")],file="../../typicality_exp3.csv",row.names=F,quote=F)
