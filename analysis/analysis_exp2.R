library(dplyr)
library(ggplot2)
library(bootstrap)
library(lme4)
library(tidyr)
library(tidyverse)
library(here)

theme_set(theme_bw(18))
source(here("analysis","helper_scripts","helpers.r"))

df = read.table(file=here("data","data_exp2.csv"),sep="\t", header=T, quote="")

# Get color-blind friendly palette that also looks good in black and white
# http://dr-k-lo.blogspot.com/2013/07/a-color-blind-friendly-palette-for-r.html
cbPalette <- c("#000000", "#009E73", "#e79f00", "#9ad0f3", "#0072B2", "#D55E00", "#CC79A7", "#F0E442")

############################
# Mixed effects regression #
############################

# Read cost file
cost = read.csv(here("data","cost_exp2.csv"),header=TRUE)
row.names(cost) = cost$target

production = df
production = droplevels(production[production$UttforBDA != "other",])

# Encode informativity and color competitor presence as binary
production$Informative = as.factor(ifelse(production$context %in% c("informative","informative-cc"),"informative","overinformative"))
production$CC = as.factor(ifelse(production$context %in% c("informative-cc","overinformative-cc"),"cc","no-cc"))

an = production[,c("gameid","context","NormedTypicality","Informative","CC","Item","ColorAndType","Color")]

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

anova(m.1,m.2) # interaction effect of typicality and informativity not justified
anova(m.1,m.3) # interaction effect of both typicality-informativity and typicality-color competitor presence not justified

###################################################
# Plot utterance choice proportions by typicality #
###################################################

# plot utterance choice proportions by typicality thick for poster/thesis -- this code is duplicated in modelAnalysis.Rmd
agr = df %>%
  select(Color,Type,ColorAndType,Other,NormedTypicality,context) %>%
  gather(Utterance,Mentioned,-context,-NormedTypicality) %>%
  group_by(Utterance,context,NormedTypicality) %>%
  summarise(Probability=mean(Mentioned),ci.low=ci.low(Mentioned),ci.high=ci.high(Mentioned))
agr = as.data.frame(agr)
agr$YMin = agr$Probability - agr$ci.low
agr$YMax = agr$Probability + agr$ci.high
# change order of Utterance column
agr$Utterance <- case_when(
  agr$Utterance == "Type" ~ "type-only",
  agr$Utterance == "Color" ~ "color-only",
  agr$Utterance == "ColorAndType" ~ "color-and-type",
  agr$Utterance == "Other" ~ "other")
# change order of levels
agr$Utterance <- factor(agr$Utterance, levels=c("type-only", "color-only", "color-and-type", "other"))
# change context names to have nicer facet labels 
levels(agr$context) = c("informative","informative-cc", "overinformative", "overinformative-cc")
# plot
scale_value = 1
ggplot(agr, aes(x=NormedTypicality,y=Probability,color=Utterance)) +
  geom_point(size=.5) +
  geom_smooth(method="lm") +
  facet_wrap(~context) +
  xlab("Typicality of object for type-only utterance") +
  ylab("Empirical utterance proportion") +
  coord_cartesian(xlim=c(0.4,1),ylim=c(0, 1)) +
  scale_color_manual(values = c(cbPalette[2],cbPalette[3],cbPalette[4],"gray30")) +
  guides(color=guide_legend(override.aes=list(fill=NA))) +
  theme(panel.border = element_rect(size=.2),
        # plot.margin = unit(x = c(0.03, 0.1, 0.03, 0.03), units = "in"),
        panel.grid = element_line(size = .4),
        axis.line        = element_line(colour = "black", size = .2),
        axis.ticks       = element_line(colour = "black", size = .2),
        axis.ticks.length = unit(2, "pt"),
        axis.text.x        = element_text(size = 6 * scale_value, colour = "black",vjust=2),
        axis.text.y        = element_text(size = 6 * scale_value, colour = "black",margin = margin(r = 0.3)),#,hjust=-5),
        axis.title.x       = element_text(size = 6 * scale_value, margin = margin(t = .5)),
        axis.title.y       = element_text(size = 6 * scale_value, margin = margin(r = .7)),
        legend.text      = element_text(margin = margin(l = -2, r=0, unit = "pt"), size = 6 * scale_value),
        legend.title     = element_text(size = 6, face = "bold"),
        legend.position  = "bottom",#c(0.5,-.5),
        legend.direction = "horizontal",
        legend.box = "vertical",
        legend.spacing.x = unit(1, 'pt'),
        legend.spacing.y = unit(5, 'pt'),
        legend.box.spacing = unit(.1,"pt"),
        legend.margin=margin(0,0,-10,0), # change space between sub-legends
        legend.box.margin=margin(0,0,0,0), # change space between legend and plot
        legend.key=element_blank(),
        strip.text      = element_text(size = 6 * scale_value,margin=margin(t=3,b=3,unit="pt"))
  )
# ggsave(file=paste("../writing/pics/exp2-cost-",costs,"-sem-",semantics,"-paramposteriors.pdf",sep=""),width=9,height=2)

# banana cases were circled by hand and then this edited graph is used in the paper
# ggsave(here("writing","pics","empiricalProportions_typ_nobanana.png"),width=30,height=30)

################################################
# Plot overview on typicality norming results #
################################################

apriori_typ = read.csv(file=here("analysis","helper_scripts","apriori-typicalities_exp2.csv"))
row.names(apriori_typ) = apriori_typ$Utterance
typicality = read.csv(file=here("data","typicality_exp2.csv")) %>%
  mutate(Combo = paste(Color,Item)) %>% 
  mutate_at(vars(Utterance,Color,Item,Combo),funs(as.character(.))) %>% 
  mutate(AprioriTypicality = ifelse((Utterance == Color | Utterance == Item | Utterance == Combo),
                              as.character(apriori_typ[Combo,]$AprioriTypicality), "other"))

summ = typicality %>%
  select(Typicality,UtteranceType,AprioriTypicality) %>% 
  group_by(UtteranceType,AprioriTypicality) %>%
  summarise(MeanTypicality=mean(Typicality),ci.low=ci.low(Typicality),ci.high=ci.high(Typicality))
summ$YMin = summ$MeanTypicality - summ$ci.low
summ$YMax = summ$MeanTypicality + summ$ci.high

# change order of levels
summ$UtteranceType = factor(summ$UtteranceType, levels=c("type-only", "color-only", "color-and-type"))
summ$AprioriTypicality = factor(summ$AprioriTypicality, levels=c("typical", "midtypical", "atypical","other"))

ggplot(summ, aes(x=AprioriTypicality,y=MeanTypicality)) +
  geom_col(color="black",fill="gray80") +
  facet_wrap(~UtteranceType) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25) +
  xlab("A priori typicality") +
  ylab("Mean typicality rating")
ggsave(here("writing","pics","exp2colortypicalitymeans.pdf"),width = 12)

##############################################################
# Other plots (that don't appear in the paper's main section)#
##############################################################

###
# Plot utterance choice proportions by typicality for color/non-color
# this represents what was analyzed in the linear regression
###

agr = production %>%
  select(ColorMentioned,Type,Other,NormedTypicality,context) %>%
  gather(Utterance,Mentioned,-context,-NormedTypicality) %>%
  group_by(Utterance,context,NormedTypicality) %>%
  summarise(Probability=mean(Mentioned),ci.low=ci.low(Mentioned),ci.high=ci.high(Mentioned))
agr = as.data.frame(agr)
agr$YMin = agr$Probability - agr$ci.low
agr$YMax = agr$Probability + agr$ci.high
# change order of Utterance column
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
                       labels=c("color-mentioned\n(color-only, color-type)", "type-only", "other")) +
  xlab("Typicality") +
  ylab("Empirical utterance proportion") +
  scale_color_manual(values=c("#56B4E9", "pink", "#999999")) +
  theme(axis.title=element_text(size=14,colour="#757575")) +
  theme(axis.text.x=element_text(size=10,colour="#757575")) +
  theme(axis.text.y=element_text(size=10,colour="#757575")) +
  theme(axis.ticks=element_line(size=.25,colour="#757575"), axis.ticks.length=unit(.75,"mm")) +
  theme(strip.text.x=element_text(size=12,colour="#757575")) +
  theme(legend.title=element_text(size=14,color="#757575")) +
  theme(legend.text=element_text(size=11,colour="#757575")) +
  theme(strip.background=element_rect(colour="#939393",fill="white")) +
  theme(panel.background=element_rect(colour="#939393"))

###
# Plot empirical results by-item variation
###

production$binTyp = ifelse(production$NormedTypicality >= 0.784, 'typical', 'atypical')
production$binContext = ifelse(production$context == "overinformative-cc", 'overinformative', 
                               ifelse(production$context == "informative-cc", 'informative', as.character(production$context)))

agr = production %>%
  group_by(binContext,Item,binTyp) %>%
  summarise(PropColorMentioned=mean(ColorMentioned),ci.low=ci.low(ColorMentioned),ci.high=ci.high(ColorMentioned))
agr = as.data.frame(agr)
agr$YMin = agr$PropColorMentioned - agr$ci.low
agr$YMax = agr$PropColorMentioned + agr$ci.high

agr$binTyp = factor(agr$binTyp, levels=c("typical","atypical"))

ggplot(agr, aes(x=binTyp,y=PropColorMentioned,color=Item,linetype=binContext,group=interaction(binContext,Item))) +
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
# Empirical length vs. theoretical length
# empirical length: length of actually produced utterances
# theoretical length: length of the clean utterance as it was categorized
###

production$empiricalLength = str_length(production$refExp)
production$theoreticalLength = str_length(production$UttforBDA)

agr = production[production$UtteranceType!="OTHER",c("empiricalLength","theoreticalLength","UtteranceType","Item")]

# by item
ggplot(agr,aes(x=empiricalLength,y=theoreticalLength)) +
  geom_abline(intercept = 0, slope = 1, color="lightblue") +
  geom_point(alpha=0.05) +
  facet_wrap(~UtteranceType) +
  xlim(0,30) +
  ylim(0,30)

# by utterance type
ggplot(agr,aes(x=empiricalLength,y=theoreticalLength)) +
  geom_abline(intercept = 0, slope = 1, color="lightblue") +
  geom_point(alpha=0.05) +
  facet_wrap(~Item) +
  xlim(0,30) +
  ylim(0,30)

###
# Plot correlation between empirically elicited type-only typicalities 
# and empirically elicited color-type typicalities
###

agr = agr %>%
  select(-Item) %>% 
  group_by(UtteranceType) %>%
  summarize(MeanEmpLength=mean(empiricalLength),MeanTheorLength=mean(theoreticalLength))
agr$OverallDiff = agr$MeanEmpLength-agr$MeanTheorLength
agr

typ_coltype = read.csv(file=here("data","raw","norming_exp2","typicality_exp2_color-and-type.csv"))
typ_coltype = typ_coltype[paste(typ_coltype$Color,typ_coltype$Item,sep=" ") == as.character(typ_coltype$Utterance),]
row.names(typ_coltype) = typ_coltype$Utterance
typ_coltype = rename(typ_coltype,ColTypeTypicality = Typicality)
typ_coltype = select(typ_coltype,Item,Color,Utterance,ColTypeTypicality)


typ = read.csv(file=here("data","raw","norming_exp2","typicality_exp2_type.csv"))
typ = typ[as.character(typ$Item) == as.character(typ$Utterance),]
row.names(typ) = paste(typ$Color,typ$Item)
typ$Utterance = paste(typ$Color,typ$Item)
typ = select(typ,Typicality,Utterance)

summ = merge(typ_coltype,typ,by="Utterance")

ggplot(summ,aes(x=Typicality,y=ColTypeTypicality)) +
  geom_point() +
  geom_text(aes(label=Utterance),hjust=-.1, vjust=0) +
  ylim(0,1) +
  xlim(0,1)

cor(summ$Typicality,summ$ColTypeTypicality)