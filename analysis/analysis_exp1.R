library(tidyverse)
library(gridExtra)
library(brms)
theme_set(theme_bw(18))
source("helper_scripts/helpers.r")
source("helper_scripts/createLaTeXTable.R")

# Read data
d = read.table(file="../data/data_exp1.csv",sep="\t", header=T, quote="")
nrow(d)

#################################################################
# Plot proportion of redundant utterances by redundant property #
#################################################################

agr = d %>%
  select(redundant,RedundantProperty,NumDistractors,SceneVariation) %>%
  gather(Utterance,Mentioned,-RedundantProperty,-NumDistractors,-SceneVariation) %>%
  group_by(Utterance,RedundantProperty,NumDistractors,SceneVariation) %>%
  summarise(Probability=mean(Mentioned),ci.low=ci.low(Mentioned),ci.high=ci.high(Mentioned)) %>%
  ungroup() %>%
  mutate(YMin = Probability - ci.low, YMax = Probability + ci.high, Distractors=as.factor(NumDistractors))

ggplot(agr, aes(x=SceneVariation,y=Probability,shape=Distractors,group=1)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  xlab("Scene variation") +
  ylab("Probability of redundant modifier") +
  scale_shape_discrete(name = "Number of\ndistractors") +
  facet_wrap(~RedundantProperty) 

############################
# Mixed effects regression #
############################

# Center predictors
centered = cbind(d, myCenter(d[,c("SufficientProperty","Trial","SceneVariation")]))
contrasts(centered$redUtterance)
contrasts(centered$SufficientProperty)

pairscor.fnc(centered[,c("redUtterance","SufficientProperty","SceneVariation")])

# Main analysis reported in paper along with Fig. 8
m = glmer(redUtterance ~ cSufficientProperty*cSceneVariation + (1|gameid) + (1|clickedType), data=centered, family="binomial")
summary(m)

# Simple effects analysis reported in paper along with Fig. 8
m.simple = glmer(redUtterance ~ SufficientProperty*cSceneVariation - cSceneVariation + (1|gameid) + (1|clickedType), data=centered, family="binomial")
summary(m.simple)

# Supplementary analysis: do the analysis only on those cases that have scene variation > 0
centered = cbind(d[d$SceneVariation > 0,], myCenter(d[d$SceneVariation > 0,c("SufficientProperty","Trial","SceneVariation")]))
contrasts(centered$redUtterance)
contrasts(centered$SufficientProperty)

m = glmer(redUtterance ~ cSufficientProperty*cSceneVariation + (1+cSceneVariation|gameid) + (1|clickedType), data=centered, family="binomial")
summary(m) # doing the analysis only on the ratio > 0 cases gets rid of the interaction, ie variation has the same effect on color-redundant and size-redunant trials. (that is, the big scene variation slope in the color-redundant condition was driven mostly by the 0-ratio cases)

# Because of lmer's convergence issues, do the Bayesian regression, which yields the same qualitative results with maximal random effects structure
m.b.full = brm(redUtterance ~ cSufficientProperty*cSceneVariation + (1+cSufficientProperty*cSceneVariation|gameid) + (1+cSufficientProperty*cSceneVariation|clickedType), data=centered, family="bernoulli")
summary(m.b.full)

plot(m.b.full, pars = c("cSufficientProperty"))
plot(m.b.full, pars = c("cSceneVariation"))
plot(m.b.full, pars = c("cSufficientProperty:cSceneVariation"))

# posterior probability of sufficient property beta > 0
mean(posterior_samples(m.b.full, pars = "b_cSufficientProperty") > 0)
mean(posterior_samples(m.b.full, pars = "b_cSceneVariation") > 0)
mean(posterior_samples(m.b.full, pars = "b_cSufficientProperty:cSceneVariation") > 0)

##############################################
# Typicality analysis reported in Appendix E #
##############################################
d$ratioTypicalityUnModmod = d$ColorTypicalityUnModified/d$ColorTypicalityModified
d$ratioTypicalityModUnmod = d$ColorTypicalityModified/d$ColorTypicalityUnModified
d$diffTypicalityModUnmod = d$ColorTypicalityModified - d$ColorTypicalityUnModified
d$diffOtherTypicalityModUnmod = d$OtherColorTypicalityModified - d$OtherColorTypicalityUnModified
d$ratioTypDiffs = d$diffTypicalityModUnmod/d$diffOtherTypicalityModUnmod
d$diffTypDiffs = d$diffTypicalityModUnmod - d$diffOtherTypicalityModUnmod
d$ColorclickedType = as.factor(paste(d$clickedColor,d$clickedType))

# These clickedTypes with the maximal typicality difference between clickedTypes of a pair are also the four cases with non-overlapping error bars in their typicality means for one of their colors
maxclickedTypes = unique(d[order(d[,c("diffTypicalityModUnmod")],decreasing=T),c("clickedType","clickedColor","diffTypicalityModUnmod")])$clickedType[1:4]
maxt = droplevels(subset(d, d$clickedType %in% maxclickedTypes))
nrow(maxt)
agr = maxt %>%
  group_by(clickedColor,clickedType,ColorclickedType,SufficientProperty,diffTypicalityModUnmod) %>%
  summarize(ProportionRedundant = mean(redundant), CILow = ci.low(redundant), CIHigh = ci.high(redundant))
agr = as.data.frame(agr)
agr$YMin = agr$ProportionRedundant - agr$CILow
agr$YMax = agr$ProportionRedundant + agr$CIHigh

ggplot(agr, aes(x=diffTypicalityModUnmod,y=ProportionRedundant,color=clickedType,group=clickedType)) +
  geom_point() +
  geom_line(size=2) +
  scale_x_continuous(name="Typicality gain",limits=c(-.15,.45),breaks=seq(-.1,.4,by=.1)) +
  ylab("Proportion of redundant utterances") +
  geom_text(aes(label=clickedColor,y=ProportionRedundant+.05),size=6) +
  facet_wrap(~SufficientProperty)
ggsave("../writing/pics/maxtypicalitydiff.pdf",width=10,height=4.5)

# Perform analysis only on cases with real typicality gain differences
centered = cbind(maxt, myCenter(maxt[,c("SufficientProperty","NumDistractors","NumSameDistractors","Trial","SceneVariation","ColorTypicality","normTypicality","TypicalityDiff","ColorTypicalityModified","normTypicalityModified","TypicalityDiffModified","ColorTypicalityUnModified","normTypicalityUnModified","TypicalityDiffUnModified","ratioTypicalityUnModmod","ratioTypicalityModUnmod","diffTypicalityModUnmod","ratioTypDiffs","diffTypDiffs")]))
contrasts(centered$redUtterance)
summary(centered)
nrow(centered)

summary(centered[,c("SceneVariation","redUtterance","diffTypicalityModUnmod","SufficientProperty")])

# Typicality operationalization: diff mod - unmod (typicality gain)
# The following two models are currently reported in the paper in Appendix E
m.diff = glmer(redUtterance ~ cSceneVariation + cSufficientProperty + cSceneVariation:cSufficientProperty + cdiffTypicalityModUnmod:cSufficientProperty + (1|gameid) + (1|ColorclickedType), data=centered, family="binomial")
summary(m.diff)
createLatexTable(m.diff,predictornames=c("Intercept","Scene variation","Sufficient property","Scene variation : Sufficient property","Sufficient property : Typicality gain"))

m.diff.simple = glmer(redUtterance ~ cSceneVariation  + cSceneVariation:SufficientProperty + SufficientProperty*cdiffTypicalityModUnmod - cdiffTypicalityModUnmod + (1|gameid) + (1|ColorclickedType), data=centered, family="binomial")
summary(m.diff.simple)

# Typicality operationalization: "pure typicality" (a la Westerbeek) reported in paper in Appendix E
m = glmer(redUtterance ~ cSceneVariation + cSufficientProperty + cSceneVariation:cSufficientProperty+cColorTypicality:cSufficientProperty + (1|gameid) + (1|ColorclickedType), data=centered, family="binomial")
summary(m)

m.simple = glmer(redUtterance ~ cSceneVariation + cSufficientProperty + cSceneVariation:cSufficientProperty+cColorTypicality:SufficientProperty - cColorTypicality + (1|gameid) + (1|ColorclickedType), data=centered, family="binomial")
summary(m.simple)


# Analysis on whole dataset
centered = cbind(d, myCenter(d[,c("SufficientProperty","NumDistractors","NumSameDistractors","Trial","SceneVariation","ColorTypicality","normTypicality","TypicalityDiff","ColorTypicalityModified","normTypicalityModified","TypicalityDiffModified","ColorTypicalityUnModified","normTypicalityUnModified","TypicalityDiffUnModified","ratioTypicalityUnModmod","ratioTypicalityModUnmod","diffTypicalityModUnmod","ratioTypDiffs","diffTypDiffs")]))
contrasts(centered$redUtterance)
summary(centered)
nrow(centered)

# Typicality operationalization: diff mod - unmod (typicality gain)
# The following model is currently reported in the paper (footnote)
m.diff = glmer(redUtterance ~ cSceneVariation  + cSufficientProperty + cSceneVariation:cSufficientProperty + cdiffTypicalityModUnmod:cSufficientProperty + (1|gameid) + (1|clickedType), data=centered, family="binomial")
summary(m.diff)

m.diff.simple = glmer(redUtterance ~ cSceneVariation  + cSceneVariation:SufficientProperty + SufficientProperty*cdiffTypicalityModUnmod - cdiffTypicalityModUnmod + (1|gameid) + (1|clickedType), data=centered, family="binomial")
summary(m.diff.simple)

m.diff.simple.notyp = glmer(redUtterance ~ cSceneVariation  + cSceneVariation:SufficientProperty + SufficientProperty + (1|gameid) + (1|clickedType), data=centered, family="binomial")
summary(m.diff.simple.notyp)

anova(m.diff.simple.notyp,m.diff.simple) # model comparison votes against typicality

# "pure typicality" (Westerbeek) reported in footnote
m = glmer(redUtterance ~ cSceneVariation + cSufficientProperty + cSceneVariation:cSufficientProperty+cColorTypicality:cSufficientProperty + (1|gameid) + (1|ColorclickedType), data=centered, family="binomial")
summary(m)

# Correlations reported in paper:
cor(d$diffTypicalityModUnmod,d$ColorTypicality)
cor(d$ColorTypicalityModified,d$ColorTypicality)
cor(d$ColorTypicalityUnModified,d$ColorTypicality)

# histogram of typicalities reported in paper
gathered = d %>%
  select(ColorTypicalityModified,ColorTypicalityUnModified) %>%
  gather(TypicalityType,Value)
gathered$UtteranceType = as.factor(ifelse(gathered$TypicalityType == "ColorTypicalityModified","modified","unmodified"))

dens = ggplot(gathered, aes(x=Value,fill=UtteranceType)) +
  geom_density(alpha=.3) +
  xlab("Typicality") +
  scale_fill_discrete(name="Utterance type") +
  theme(legend.position=c(0.2,.85))

diffs = ggplot(d, aes(x=diffTypicalityModUnmod)) +
  geom_histogram(binwidth=.03) +
  xlab("Typicality gain") +
  geom_vline(xintercept=0,color="blue")

pdf("../writing/pics/typicality-dists.pdf",height=4,width=11)
grid.arrange(dens,diffs,nrow=1)
dev.off()

# Means and SDs reported in paper
mean(d$ColorTypicalityModified)
sd(d$ColorTypicalityModified)
mean(d$ColorTypicalityUnModified)
sd(d$ColorTypicalityUnModified)
