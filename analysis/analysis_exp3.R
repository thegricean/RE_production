library(tidyverse)
library(languageR)
library(lme4)
library(MuMIn)
library(brms)
theme_set(theme_bw(18))
source("helper_scripts/helpers.R")
source("helper_scripts/createLaTeXTable.R")

d = read.csv(file="../data/data_exp3.csv",sep="\t")
nrow(d)

#### Add costs and typicality:

# Add costs
costs = read.table(file="../data/cost_exp3.csv",sep=",", header=T, quote="")
row.names(costs) = as.character(costs$target)

d$freq_sub = costs[as.character(d$target_sub),]$freq
d$freq_basic = costs[as.character(d$target_basic),]$freq
d$freq_super = costs[as.character(d$target_super),]$freq

d$log_freq_sub = log(d$freq_sub)
d$log_freq_basic = log(d$freq_basic)
d$log_freq_super = log(d$freq_super)
  
d$diff_logfreq_subbasic = d$log_freq_sub - d$log_freq_basic
d$diff_logfreq_subsuper = d$log_freq_sub - d$log_freq_super

costs$precodedLength = nchar(as.character(costs$target))

# empirical
d$mean_length_sub = costs[as.character(d$target_sub),]$length
d$mean_length_basic =  costs[as.character(d$target_basic),]$length
d$mean_length_super =  costs[as.character(d$target_super),]$length

# precoded
d$precoded_length_sub = costs[as.character(d$target_sub),]$precodedLength
d$precoded_length_basic =  costs[as.character(d$target_basic),]$precodedLength
d$precoded_length_super =  costs[as.character(d$target_super),]$precodedLength

d$ratio_length_subbasic = d$mean_length_sub/d$mean_length_basic
d$ratio_length_subsuper = d$mean_length_sub/d$mean_length_super

# get length/frequency correlation
costs$logFreq = log(costs$freq)
cor(costs$logFreq,costs$length) # -.44


# Add typicality values
typs = read.table("../data/typicality_exp3.csv",header=T,quote="",sep=",")
head(typs)
ttyps = droplevels(subset(typs, itemtype == "target"))
row.names(ttyps) = paste(ttyps$labeltype, ttyps$item)
d$typ_sub = ttyps[paste("sub",as.character(d$target_sub)),]$meanresponse
d$typ_basic = ttyps[paste("basic",as.character(d$target_sub)),]$meanresponse
d$typ_super = ttyps[paste("super",as.character(d$target_sub)),]$meanresponse

d$ratio_typ_subbasic = d$typ_sub/d$typ_basic
d$ratio_typ_subsuper = d$typ_sub/d$typ_super


### Some supplementary qualitative analyses:

# very few super mentions
prop.table(table(d$condition,d$super),margin = 1)
prop.table(table(d$condition,d$basic), margin=1)

table(d$target_basic)
table(d[d$super,]$target_basic)
table(d[d$sub,]$target_basic)



#################################################
#################  ANALYSIS  ####################
#################################################

# TYPE MENTION WITH DOMAIN-LEVEL RANDOM EFFECTS #

centered = cbind(d, myCenter(d[,c("mean_length_sub","mean_length_basic","mean_length_super","log_freq_sub","log_freq_basic","log_freq_super","diff_logfreq_subbasic","diff_logfreq_subsuper","ratio_length_subbasic","ratio_length_subsuper","typ_sub","typ_basic","typ_super","ratio_typ_subbasic","ratio_typ_subsuper","binaryCondition")]))

# check: do you need four-level condition difference?
contrasts(centered$condition) = cbind("12.vs.rest"=c(3/4,-1/4,-1/4,-1/4),"22.vs.3"=c(0,2/3,-1/3,-1/3),"23.vs.33"=c(0,0,1/2,-1/2))
contrasts(centered$redCondition) = cbind("sub.vs.rest"=c(-1/3,2/3,-1/3),"basic.vs.super"=c(1/2,0,-1/2))

pairscor.fnc(centered[,c("cdiff_logfreq_subbasic","cratio_length_subbasic","cratio_typ_subbasic","redCondition","sub")])

m.1 = glmer(sub ~ condition + (1|gameid) + (1|target_sub), family="binomial", data=centered)
summary(m.1)          

m.2 = glmer(sub ~ redCondition + (1|gameid) + (1|target_sub), family="binomial", data=centered)
summary(m.2)          

m.3 = glmer(sub ~ cbinaryCondition + (1|gameid) + (1|target_sub), family="binomial", data=centered)
summary(m.3)          

anova(m.1,m.2) # most complex condition (4 levels) not justified
anova(m.2,m.3) # more complex condition (3 levels, collapsing across 22 and 23) justified

m.2.lfcomplex = glmer(sub ~ redCondition + cdiff_logfreq_subbasic + cratio_length_subbasic + cdiff_logfreq_subsuper + cratio_length_subsuper + (1|gameid) + (1|target_sub), family="binomial", data=centered)
summary(m.2.lfcomplex)

m.2.lf = glmer(sub ~ redCondition + cdiff_logfreq_subbasic + cratio_length_subbasic + (1|gameid) + (1|target_sub), family="binomial", data=centered)
summary(m.2.lf)

anova(m.2.lf,m.2.lfcomplex) # the sub:super diffs/ratios don't matter

m = glmer(sub ~ redCondition + cdiff_logfreq_subbasic + cratio_length_subbasic + (1|gameid) + (1|target_sub) , family="binomial",data=centered) 

summary(m) # frequency doesn't appear to matter one bit
createLatexTable(m,predictornames=c("Intercept","Condition sub.vs.rest","Condition basic.vs.super","Length","Frequency","Length:Frequency"))

# add typicality -- main analysis reported in the psych review paper
m.m.t = glmer(sub ~ redCondition + cdiff_logfreq_subbasic + cratio_length_subbasic + cratio_typ_subbasic + (1|gameid) + (1|target_sub) , family="binomial",data=centered) 
summary(m.m.t)
createLatexTable(m.m.t,predictornames=c("Intercept","Condition sub.vs.rest","Condition basic.vs.super","Length","Frequency","Typicality"))

anova(m,m.m.t) # typicality very important!

# add length/frequency interaction term -- it does nothing
m.m.t.inter = glmer(sub ~ redCondition + cdiff_logfreq_subbasic + cratio_length_subbasic + cdiff_logfreq_subbasic:cratio_length_subbasic + cratio_typ_subbasic + (1|gameid) + (1|target_sub) , family="binomial",data=centered) 
summary(m.m.t.inter)

# code condition as binary predictor to see whether the three-way predictor is really important

m.m.t.bin = glmer(sub ~ cbinaryCondition + cdiff_logfreq_subbasic + cratio_length_subbasic + cratio_typ_subbasic + (1|gameid) + (1|target_sub) , family="binomial",data=centered) 

anova(m.m.t.bin,m.m.t) # 3-way condition important!

# typicality model with most complex condition to test whether it matters once you take into account typicality
m.m.t.c = glmer(sub ~ condition + cdiff_logfreq_subbasic * cratio_length_subbasic + cratio_typ_subbasic + (1|gameid) + (1|target_sub) , family="binomial",data=centered) 
summary(m.m.t.c)

anova(m.m.t,m.m.t.c) # nope, no value added by more complex condition

# get marginal and conditional R squared
r.squaredGLMM(m)
r.squaredGLMM(m.m.t) # increase of .06 in marginal R2, so typicality certainly explains variance
r.squaredGLMM(m.m.t.c) # further increase in explained variance with most complex condition close to 0

m.m.t.norandom = glm(sub ~ redCondition + cdiff_logfreq_subbasic * cratio_length_subbasic + cratio_typ_subbasic, family="binomial",data=centered) 
summary(m.m.t.norandom) # without random effects, frequency matters

anova(m.m.t.norandom,m.m.t)

empirical = centered %>%
  select(sub)
empirical$Fitted = fitted(m.m.t.norandom)
empirical$Prediction = ifelse(empirical$Fitted >= .5, T, F)
empirical$FittedM = fitted(m.m.t)
empirical$PredictionM = ifelse(empirical$FittedM >= .5, T, F)
cor(empirical$sub,empirical$Prediction)
cor(empirical$sub,empirical$PredictionM) # better correlation with than without random effects

# do a brms analysis with more conservative (ie, fuller) random effects structure (reported in paper in footnote)
m.m.t.b = brm(sub ~ redCondition + cdiff_logfreq_subbasic + cratio_length_subbasic + cratio_typ_subbasic + (1+redCondition + cdiff_logfreq_subbasic + cratio_length_subbasic + cratio_typ_subbasic|gameid) + (1+redCondition + cdiff_logfreq_subbasic + cratio_length_subbasic + cratio_typ_subbasic|target_sub) , family="bernoulli",data=centered) 
summary(m.m.t.b)

mean(posterior_samples(m.m.t.b, pars = "b_redCondition") > 0)
mean(posterior_samples(m.m.t.b, pars = "b_cratio_typ_subbasic") > 0)
mean(posterior_samples(m.m.t.b, pars = "b_cratio_length_subbasic") < 0)

######### PAPER PLOTS

# overall pattern
agr = d %>%
  select(redCondition,target_sub,typ_sub,sub,basic,super) %>%
  gather(Utt,Mentioned,-redCondition,-target_sub,-typ_sub) %>%
  group_by(Utt,redCondition,target_sub,typ_sub) %>%
  summarise(Probability=mean(Mentioned),ci.low=ci.low(Mentioned),ci.high=ci.high(Mentioned)) %>%
  ungroup() %>%
  mutate(YMin=Probability-ci.low,YMax=Probability+ci.high) %>%
  mutate(redCondition=fct_recode(redCondition,"sub necessary"="sub_necessary","basic sufficient"="basic_sufficient","super sufficient"="super_sufficient"),Utterance=fct_relevel(Utt,c("sub","basic","super")))
agr$item = ""
agr[agr$target_sub == "parrot",]$item = "parrot"
agr[agr$target_sub == "poloshirt",]$item = "poloshirt"
agr[agr$target_sub == "suv",]$item = "suv"

ggplot(agr, aes(x=typ_sub,y=Probability,color=Utterance)) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_text(aes(label=item),nudge_y=.04) +
  ylab("Empirical utterance proportion") +
  xlab("Typicality of object for subordinate level utterance") +
  facet_wrap(~fct_relevel(redCondition,c("sub necessary","basic sufficient","super sufficient"))) +
  theme(legend.position="top")
# see modelAnalysis.Rmd for code that generates this figure jointly with model predictions 

# overall pattern, collapsed
agr = d %>%
  select(sub,basic,super, condition) %>%
  gather(Utt,Mentioned,-condition) %>%
  group_by(Utt,condition) %>%
  summarise(Probability=mean(Mentioned),ci.low=ci.low(Mentioned),ci.high=ci.high(Mentioned))
agr = as.data.frame(agr)
agr$YMin = agr$Probability - agr$ci.low
agr$YMax = agr$Probability + agr$ci.high
summary(agr)
dodge = position_dodge(.9)
agr$Utt = as.factor(ifelse(agr$Utt == "sub","sub",ifelse(agr$Utt == "basic","basic","super")))
agr$Utterance = factor(x=as.character(agr$Utt),levels=c("sub","basic","super"))

ggplot(agr, aes(x=condition,y=Probability)) +
  geom_bar(stat="identity",position=dodge) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25, position=dodge) +
  facet_wrap(~Utterance) +
  ylab("Proportion of utterance choice") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))


# correlation between mean empirical length and ratio of sub to basic length
cor(d$mean_length_sub,d$ratio_length_subbasic) # r=.84 between mean length and sub to basic ratio
cor(d$mean_length_sub,d$ratio_length_subsuper) # r=.83 between mean length and sub to super ratio


