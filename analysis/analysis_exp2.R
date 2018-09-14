library(dplyr)
library(ggplot2)
library(bootstrap)
library(lme4)
library(tidyr)
library(here)

theme_set(theme_bw(18))
source(here("analysis","helper_scripts","helpers.r"))

production = read.table(file=here("data","data_exp2.csv"),sep="\t", header=T, quote="")

############################
# Mixed effects regression #
############################

# Read cost file
cost = read.csv(here("data","cost_exp2.csv"),header=TRUE)
row.names(cost) = cost$target

production = droplevels(production[production$UttforBDA != "other",])

# 
# production$ColTypeLength = cost[as.character(production$Target),]$length
# # This is a LogProbability
# production$ColTypeFreq = cost[as.character(production$Target),]$freq
# production$TypeLength = cost[as.character(production$Item),]$length
# production$TypeFreq = cost[as.character(production$Item),]$freq
# production$ColorLength = cost[as.character(production$TargetColor),]$length
# production$ColorFreq = cost[as.character(production$TargetColor),]$freq

# Encode informativity and color competitor presence as binary
production$Informative = as.factor(ifelse(production$context %in% c("informative","informative-cc"),"informative","overinformative"))
production$CC = as.factor(ifelse(production$context %in% c("informative-cc","overinformative-cc"),"cc","no-cc"))

# Exclude all "other" utterances
an = production[,c("gameid","context","NormedTypicality","Informative","CC","Item","ColorAndType","Color")]
# nrow(an)

centered = cbind(an,myCenter(an[,c("NormedTypicality","Informative","CC")]))
# ColorOrType is the same as ColorMentioned
centered$ColorOrType = centered$ColorAndType | centered$Color

# Informative is a negative value, Overinformative is a positive value
# CC is negative, nonCC is positive

m.1 = glmer(ColorOrType ~ cNormedTypicality + cInformative + cCC + (1|gameid) + (1|Item), data = centered, family="binomial")
summary(m.1)
# ranef(m.1)

m.2 = glmer(ColorOrType ~ cNormedTypicality + cInformative + cCC + cNormedTypicality : cInformative + (1|gameid) + (1|Item), data = centered, family="binomial")
summary(m.2)
# ranef(m.2)

m.3 = glmer(ColorOrType ~ cNormedTypicality + cInformative + cCC + cNormedTypicality : cInformative + cNormedTypicality:cCC + (1|gameid) + (1|Item), data = centered, family="binomial")
summary(m.3)
# ranef(m.3)

anova(m.1,m.2)
anova(m.1,m.3)

###################################################
# Plot utterance choice proportions by typicality #
###################################################

# plot utterance choice proportions by typicality thick for poster/thesis
agr = production %>%
  select(Color,Type,ColorAndType,Other,NormedTypicality,context) %>%
  gather(Utterance,Mentioned,-context,-NormedTypicality) %>%
  group_by(Utterance,context,NormedTypicality) %>%
  summarise(Probability=mean(Mentioned),ci.low=ci.low(Mentioned),ci.high=ci.high(Mentioned))
agr = as.data.frame(agr)
agr$YMin = agr$Probability - agr$ci.low
agr$YMax = agr$Probability + agr$ci.high
# change order of Utterance column
agr$Utterance <- ifelse(agr$Utterance == "Type", "type-only",
                        ifelse(agr$Utterance == "Color", "color-only",
                               ifelse(agr$Utterance == "ColorAndType", "color-and-type",
                                      ifelse(agr$Utterance == "Other", "other","ERROR"))))
agr$Utterance <- as.factor(agr$Utterance)
agr$Utterance <- factor(agr$Utterance, levels=c("type-only", "color-only", "color-and-type", "other"))

# change context names to have nicer facet labels 
levels(agr$context) = c("informative","informative-cc", "overinformative", "overinformative-cc")
# plot
ggplot(agr, aes(x=NormedTypicality,y=Probability,color=Utterance)) +
  geom_point(size=2) +
  geom_smooth(method="lm",size=2.25) +
  facet_wrap(~context) +
  xlab("Typicality of object for type-only utterance") +
  ylab("Empirical utterance proportion") +
  coord_cartesian(xlim=c(0.4,1),ylim=c(0, 1)) +
  scale_color_manual(values=c("#56B4E9", "#E69F00", "#9fdf9f", "#999999")) +
  theme(axis.title=element_text(size=25,colour="#757575")) +
  theme(axis.text.x=element_text(size=20,colour="#757575")) +
  theme(axis.text.y=element_text(size=20,colour="#757575")) +
  theme(axis.ticks=element_line(size=.5,colour="#757575"), axis.ticks.length=unit(1,"mm")) +
  theme(strip.text.x=element_text(size=25,colour="#757575")) +
  theme(legend.position="top") +
  theme(legend.title=element_text(size=25,color="#757575")) +
  theme(legend.text=element_text(size=20,colour="#757575")) +
  labs(color = "Utterance") +
  theme(strip.background=element_rect(colour="#939393",fill="white")) +
  theme(panel.background=element_rect(colour="#939393"))
# ggsave(here("writing","pics","empiricalProportions_typ_nobanana.png"),width=11,height=9)

#######################################################################
# Plot utterance choice proportions by typicality for color/non-color #
#######################################################################

agr = production %>%
  select(ColorMentioned,Type,Other,NormedTypicality,context) %>%
  gather(Utterance,Mentioned,-context,-NormedTypicality) %>%
  group_by(Utterance,context,NormedTypicality) %>%
  summarise(Probability=mean(Mentioned),ci.low=ci.low(Mentioned),ci.high=ci.high(Mentioned))
agr = as.data.frame(agr)
agr$YMin = agr$Probability - agr$ci.low
agr$YMax = agr$Probability + agr$ci.high
# change order of Utterance column
agr$Utterance <- as.character(agr$Utterance)
agr$Utterance <- factor(agr$Utterance, levels=c("ColorMentioned", "Type", "Other"))
# change context names to have nicer facet labels 
levels(agr$context) = c("informative","informative\nwith color competitor", "overinformative", "overinformative\nwith color competitor")
# plot
ggplot(agr, aes(x=NormedTypicality,y=Probability,color=Utterance)) +
  geom_point(size=.5) +
  geom_smooth(method="lm",size=.6) +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25) +
  facet_wrap(~context) +
  scale_color_discrete(name="Utterance",
                       breaks=c("ColorMentioned", "Type", "Other"),
                       labels=c("Color Mentioned", "Type Only", "Other")) +
  xlab("Typicality") +
  ylab("Empirical utterance proportion") +
  theme(axis.title=element_text(size=14,colour="#757575")) +
  theme(axis.text.x=element_text(size=10,colour="#757575")) +
  theme(axis.text.y=element_text(size=10,colour="#757575")) +
  theme(axis.ticks=element_line(size=.25,colour="#757575"), axis.ticks.length=unit(.75,"mm")) +
  theme(strip.text.x=element_text(size=12,colour="#757575")) +
  theme(legend.title=element_text(size=14,color="#757575")) +
  theme(legend.text=element_text(size=11,colour="#757575")) +
  theme(strip.background=element_rect(colour="#939393",fill="white")) +
  theme(panel.background=element_rect(colour="#939393"))

###############
# Other plots #
###############

# Plot by-item variation
production$binTyp = ifelse(production$NormedTypicality >= 0.784, 'typical', 'atypical')
production$binContext = ifelse(production$context == "overinformative-cc", 'overinformative', 
                               ifelse(production$context == "informative-cc", 'informative', as.character(production$context)))

agr = production %>%
  group_by(binContext,clickedType,binTyp) %>%
  summarise(PropColorMentioned=mean(ColorMentioned),ci.low=ci.low(ColorMentioned),ci.high=ci.high(ColorMentioned))
agr = as.data.frame(agr)
agr$YMin = agr$PropColorMentioned - agr$ci.low
agr$YMax = agr$PropColorMentioned + agr$ci.high

agr$binTyp = factor(agr$binTyp, levels=c("typical","atypical"))

ggplot(agr, aes(x=binTyp,y=PropColorMentioned,color=clickedType,linetype=binContext,group=interaction(binContext,clickedType))) +
  geom_point() +
  geom_line() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25) +
  xlab("Typicality") +
  ylab("Proportion of  \n mentioning color") +
  theme(axis.title=element_text(size=14,colour="#757575")) +
  theme(axis.text.x=element_text(size=10,colour="#757575")) +
  theme(axis.text.y=element_text(size=10,colour="#757575")) +
  theme(axis.ticks=element_line(size=.25,colour="#757575"), axis.ticks.length=unit(.75,"mm")) +
  theme(legend.title=element_text(size=14,color="#757575")) +
  theme(legend.text=element_text(size=11,colour="#757575")) +
  guides(color=guide_legend(title="Object")) +
  guides(linetype=guide_legend(title="Context"))

###
# Empirical length vs theoretical length
###

production$empiricalLength = str_length(production$refExp)
production$theoreticalLength = str_length(production$UttforBDA)

agr = production[production$UtteranceType!="OTHER",c("empiricalLength","theoreticalLength","UtteranceType","Item")]

ggplot(agr,aes(x=empiricalLength,y=theoreticalLength)) +
  geom_abline(intercept = 0, slope = 1, color="lightblue") +
  geom_point(alpha=0.05) +
  facet_wrap(~UtteranceType) +
  xlim(0,30) +
  ylim(0,30)
# ggsave(here("exp2_lengths.jpg"))

ggplot(agr,aes(x=empiricalLength,y=theoreticalLength)) +
  geom_abline(intercept = 0, slope = 1, color="lightblue") +
  geom_point(alpha=0.05) +
  facet_wrap(~Item) +
  xlim(0,30) +
  ylim(0,30)

agr = agr %>%
  select(-Item) %>% 
  group_by(UtteranceType) %>%
  summarize(MeanEmpLength=mean(empiricalLength),MeanTheorLength=mean(theoreticalLength))
agr$OverallDiff = agr$MeanEmpLength-agr$MeanTheorLength
agr


