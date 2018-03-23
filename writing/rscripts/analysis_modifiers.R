setwd("/Users/titlis/cogsci/projects/stanford/projects/overinformativeness/experiments/7_overinf_basiclevel_biggersample/results")
source("rscripts/helpers.r")
source("/Users/titlis/cogsci/projects/stanford/projects/overinformativeness/writing/2016/theory/rscripts/createLaTeXTable.R")

d = read.csv(file="data/results_for_regression.csv",quote="")
# This dataset includes the 6 cases where the insufficient dimension was underinformatively produced
d[d$redUtterance == "other",]

# To exclude these:
t = droplevels(subset(d, redUtterance %in% c("minimal","redundant")))
t$SceneVariation = t$NumDiff/t$NumDistractors
t$Item = as.factor(as.character(t$Item))
nrow(t)

centered = cbind(t, myCenter(t[,c("SufficientProperty","NumDistractors","NumSameDistractors","roundNum","SceneVariation","SceneVariation")]))
contrasts(centered$redUtterance)
contrasts(centered$SufficientProperty)

pairscor.fnc(centered[,c("redUtterance","SufficientProperty","NumDistractors","NumSameDistractors","SceneVariation","SceneVariation")])

# reported in paper along with Fig. 8
m = glmer(redUtterance ~ cSufficientProperty*cSceneVariation + (1+cSceneVariation|gameid) + (1|Item), data=centered, family="binomial")
summary(m)

# reported in paper along with Fig. 8
m.simple = glmer(redUtterance ~ SufficientProperty*cSceneVariation - cSceneVariation + (1+cSceneVariation|gameid) + (1|Item), data=centered, family="binomial")
summary(m.simple)

# do the analysis only on those cases that have variation > 0
centered = cbind(t[t$SceneVariation > 0,], myCenter(t[t$SceneVariation > 0,c("SufficientProperty","NumDistractors","NumSameDistractors","roundNum","SceneVariation","SceneVariation")]))
contrasts(centered$redUtterance)
contrasts(centered$SufficientProperty)

pairscor.fnc(centered[,c("redUtterance","SufficientProperty","NumDistractors","NumSameDistractors","SceneVariation","SceneVariation")])
m = glmer(redUtterance ~ cSufficientProperty*cSceneVariation + (1+cSceneVariation|gameid) + (1|Item), data=centered, family="binomial")
summary(m) # doing the analysis only on the ratio > 0 cases gets rid of the interaction, ie variation has the same effect on color-redundant and size-redunant trials. (that is, the big scene variation slop in hte color-redundant condition was driven mostly by the 0-ratio cases)


### TYPICALITY ANALYSIS
t$ratioTypicalityUnModmod = t$ColorTypicalityUnModified/t$ColorTypicalityModified
t$ratioTypicalityModUnmod = t$ColorTypicalityModified/t$ColorTypicalityUnModified
t$diffTypicalityModUnmod = t$ColorTypicalityModified - t$ColorTypicalityUnModified
t$diffOtherTypicalityModUnmod = t$OtherColorTypicalityModified - t$OtherColorTypicalityUnModified
t$ratioTypDiffs = t$diffTypicalityModUnmod/t$diffOtherTypicalityModUnmod
t$diffTypDiffs = t$diffTypicalityModUnmod - t$diffOtherTypicalityModUnmod
t$ColorItem = as.factor(paste(t$clickedColor,t$Item))

# these maxitems also turn out to be the four cases with non-overlapping error bars in their typicality means for one of their colors (see norming.r in experimnts/9_...)
maxitems = unique(t[order(t[,c("diffTypicalityModUnmod")],decreasing=T),c("Item","clickedColor","diffTypicalityModUnmod")])$Item[1:4]
maxt = droplevels(subset(t, t$Item %in% maxitems))
nrow(maxt)
agr = maxt %>%
  group_by(clickedColor,Item,ColorItem,SufficientProperty,diffTypicalityModUnmod) %>%
  summarize(ProportionRedundant = mean(redundant), CILow = ci.low(redundant), CIHigh = ci.high(redundant))
agr = as.data.frame(agr)
agr$YMin = agr$ProportionRedundant - agr$CILow
agr$YMax = agr$ProportionRedundant + agr$CIHigh

ggplot(agr, aes(x=diffTypicalityModUnmod,y=ProportionRedundant,color=Item,group=Item)) +
  geom_point() +
#  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line(size=2) +
  scale_x_continuous(name="Typicality gain",limits=c(-.15,.45),breaks=seq(-.1,.4,by=.1)) +
  ylab("Proportion of redundant utterances") +
  geom_text(aes(label=clickedColor,y=ProportionRedundant+.05),size=6) +
  facet_wrap(~SufficientProperty)
ggsave("/Users/titlis/cogsci/projects/stanford/projects/overinformativeness/writing/2016/theory/pics/maxtypicalitydiff.pdf",width=10,height=4.5)

# PERFORM ANALYSIS ONLY ON MAX DIFF ITEMS
centered = cbind(maxt, myCenter(maxt[,c("SufficientProperty","NumDistractors","NumSameDistractors","roundNum","SceneVariation","ColorTypicality","normTypicality","TypicalityDiff","ColorTypicalityModified","normTypicalityModified","TypicalityDiffModified","ColorTypicalityUnModified","normTypicalityUnModified","TypicalityDiffUnModified","ratioTypicalityUnModmod","ratioTypicalityModUnmod","diffTypicalityModUnmod","ratioTypDiffs","diffTypDiffs")]))
contrasts(centered$redUtterance)
summary(centered)
nrow(centered)

pairscor.fnc(centered[,c("SceneVariation","redUtterance","diffTypicalityModUnmod")])

summary(centered[,c("SceneVariation","redUtterance","diffTypicalityModUnmod","SufficientProperty")])

# diff mod - unmod (typicality gain)
# the following two are currently reported in the paper
m.diff = glmer(redUtterance ~ cSceneVariation + cSufficientProperty + cSceneVariation:cSufficientProperty + cdiffTypicalityModUnmod:cSufficientProperty + (1|gameid) + (1|ColorItem), data=centered, family="binomial")
summary(m.diff)
createLatexTable(m.diff,predictornames=c("Intercept","Scene variation","Sufficient property","Scene variation : Sufficient property","Sufficient property : Typicality gain"))

m.diff.simple = glmer(redUtterance ~ cSceneVariation  + cSceneVariation:SufficientProperty + SufficientProperty*cdiffTypicalityModUnmod - cdiffTypicalityModUnmod + (1|gameid) + (1|ColorItem), data=centered, family="binomial")
summary(m.diff.simple)

# "pure typicality" (Westerbeek) reported in paper
m = glmer(redUtterance ~ cSceneVariation + cSufficientProperty + cSceneVariation:cSufficientProperty+cColorTypicality:cSufficientProperty + (1|gameid) + (1|ColorItem), data=centered, family="binomial")
summary(m)

m.simple = glmer(redUtterance ~ cSceneVariation + cSufficientProperty + cSceneVariation:cSufficientProperty+cColorTypicality:SufficientProperty - cColorTypicality + (1|gameid) + (1|ColorItem), data=centered, family="binomial")
summary(m.simple)


# CONDUCT ANALYSIS ON WHOLE DATASET
centered = cbind(t, myCenter(t[,c("SufficientProperty","NumDistractors","NumSameDistractors","roundNum","SceneVariation","ColorTypicality","normTypicality","TypicalityDiff","ColorTypicalityModified","normTypicalityModified","TypicalityDiffModified","ColorTypicalityUnModified","normTypicalityUnModified","TypicalityDiffUnModified","ratioTypicalityUnModmod","ratioTypicalityModUnmod","diffTypicalityModUnmod","ratioTypDiffs","diffTypDiffs")]))
contrasts(centered$redUtterance)
summary(centered)
nrow(centered)

# diff mod - unmod (typicality gain)
# the following one is currently reported in the paper (footnote)
m.diff = glmer(redUtterance ~ cSceneVariation  + cSufficientProperty + cSceneVariation:cSufficientProperty + cdiffTypicalityModUnmod:cSufficientProperty + (1|gameid) + (1|Item), data=centered, family="binomial")
summary(m.diff)

m.diff.simple = glmer(redUtterance ~ cSceneVariation  + cSceneVariation:SufficientProperty + SufficientProperty*cdiffTypicalityModUnmod - cdiffTypicalityModUnmod + (1|gameid) + (1|Item), data=centered, family="binomial")
summary(m.diff.simple)

m.diff.simple.notyp = glmer(redUtterance ~ cSceneVariation  + cSceneVariation:SufficientProperty + SufficientProperty + (1|gameid) + (1|Item), data=centered, family="binomial")
summary(m.diff.simple.notyp)

anova(m.diff.simple.notyp,m.diff.simple) #hm, model comparison votes against typicality

# "pure typicality" (Westerbeek) reported in footnote
m = glmer(redUtterance ~ cSceneVariation + cSufficientProperty + cSceneVariation:cSufficientProperty+cColorTypicality:cSufficientProperty + (1|gameid) + (1|ColorItem), data=centered, family="binomial")
summary(m)


# correlations reported in paper:
cor(t$diffTypicalityModUnmod,t$ColorTypicality)
cor(t$ColorTypicalityModified,t$ColorTypicality)
cor(t$ColorTypicalityUnModified,t$ColorTypicality)

# histogram of typicalities reported in paper
gathered = t %>%
  select(ColorTypicalityModified,ColorTypicalityUnModified) %>%
  gather(TypicalityType,Value)
gathered$UtteranceType = as.factor(ifelse(gathered$TypicalityType == "ColorTypicalityModified","modified","unmodified"))

dens = ggplot(gathered, aes(x=Value,fill=UtteranceType)) +
  geom_density(alpha=.3) +
  xlab("Typicality") +
  scale_fill_discrete(name="Utterance type") +
  theme(legend.position=c(0.2,.85))

diffs = ggplot(t, aes(x=diffTypicalityModUnmod)) +
  geom_histogram(binwidth=.03) +
  xlab("Typicality gain") +
  geom_vline(xintercept=0,color="blue")

library(gridExtra)
pdf("/Users/titlis/cogsci/projects/stanford/projects/overinformativeness/writing/2016/theory/pics/typicality-dists.pdf",height=4,width=11)
grid.arrange(dens,diffs,nrow=1)
dev.off()

# means and sds reported in paper
mean(t$ColorTypicalityModified)
sd(t$ColorTypicalityModified)
mean(t$ColorTypicalityUnModified)
sd(t$ColorTypicalityUnModified)
