library(tidyverse)
theme_set(theme_bw(18))
source("helper_scripts/helpers.R")
source("helper_scripts/createLaTeXTable.R")

d = read.csv(file="../data/data_exp3.csv",sep="\t")
nrow(d)

#### Add costs and typicality:

# Add costs
costs = read.table(file="../data/cost_exp3.csv",sep=",", header=T, quote="")

d$freq_sub = costs[as.character(d$target_sub),]$relFreq
d$freq_basic = costs[as.character(d$target_basic),]$relFreq
d$freq_super = costs[as.character(d$target_super),]$relFreq

d$log_freq_sub = log(d$freq_sub)
d$log_freq_basic = log(d$freq_basic)
d$log_freq_super = log(d$freq_super)
  
d$diff_logfreq_subbasic = d$log_freq_sub - d$log_freq_basic
d$diff_logfreq_subsuper = d$log_freq_sub - d$log_freq_super

row.names(costs) = costs$noun
costs$precodedLength = nchar(as.character(costs$noun))

# empirical
d$mean_length_sub = costs[as.character(d$target_sub),]$average_length
d$mean_length_basic =  costs[as.character(d$target_basic),]$average_length
d$mean_length_super =  costs[as.character(d$target_super),]$average_length

# precoded
d$precoded_length_sub = costs[as.character(d$target_sub),]$precodedLength
d$precoded_length_basic =  costs[as.character(d$target_basic),]$precodedLength
d$precoded_length_super =  costs[as.character(d$target_super),]$precodedLength

d$ratio_length_subbasic = d$mean_length_sub/d$mean_length_basic
d$ratio_length_subsuper = d$mean_length_sub/d$mean_length_super

# get length/frequency correlation
costs$logFreq = log(costs$relFreq)
cor(costs$logFreq,costs$average_length) # -.44


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

library(languageR)
library(lme4)

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

# add typicality -- this is what's reported in the psych review paper
m.m.t = glmer(sub ~ redCondition + cdiff_logfreq_subbasic + cratio_length_subbasic + cratio_typ_subbasic + (1|gameid) + (1|target_sub) , family="binomial",data=centered) 
summary(m.m.t)
createLatexTable(m.m.t,predictornames=c("Intercept","Condition sub.vs.rest","Condition basic.vs.super","Length","Frequency","Typicality"))

anova(m,m.m.t) # typicality very important!

# add interaction term -- it does nothing
m.m.t.inter = glmer(sub ~ redCondition + cdiff_logfreq_subbasic + cratio_length_subbasic + cdiff_logfreq_subbasic:cratio_length_subbasic + cratio_typ_subbasic + (1|gameid) + (1|target_sub) , family="binomial",data=centered) 
summary(m.m.t.inter)

# code condition as binary predictor to see whether the three-way predictor is really important

m.m.t.bin = glmer(sub ~ cbinaryCondition + cdiff_logfreq_subbasic + cratio_length_subbasic + cratio_typ_subbasic + (1|gameid) + (1|target_sub) , family="binomial",data=centered) 

anova(m.m.t.bin,m.m.t) # 3-way condition important!

# typicality model with most complex condition to test whether it matters once you take into account typicality
m.m.t.c = glmer(sub ~ condition + cdiff_logfreq_subbasic * cratio_length_subbasic + cratio_typ_subbasic + (1|gameid) + (1|target_sub) , family="binomial",data=centered) 
summary(m.m.t.c)

anova(m.m.t,m.m.t.c) # nope, no value added by more complex condition

library(MuMIn)

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



######### PAPER PLOTS

# overall pattern, fig ??
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
#ggsave("graphs_basiclevel/results-collapsed.pdf",height=4.1,width=7)

agr = d %>%
  select(sub,basic,super, condition, target_basic) %>%
  gather(Utt,Mentioned,-condition, -target_basic) %>%
  group_by(Utt,condition,target_basic) %>%
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
  facet_grid(target_basic~Utterance) +
  ylab("Proportion of utterance choice") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))
#ggsave("graphs_basiclevel/results-bydomain.pdf",height=10,width=7)

# correlation between mean empirical length and ratio of sub to basic length
cor(d$mean_length_sub,d$ratio_length_subbasic) # r=.84 between mean length and sub to basic ratio
cor(d$mean_length_sub,d$ratio_length_subsuper) # r=.83 between mean length and sub to super ratio

#main effect of length
d$bin_ratio_length_subbasic = cut_number(d$ratio_length_subbasic,2,labels=c("short","long"))#,labels=c("short","mid","long"))

summary(cut_number(d$ratio_length_subbasic,2))
           
agr = d %>%
  select(sub, bin_ratio_length_subbasic,redCondition) %>%
  group_by(bin_ratio_length_subbasic,redCondition) %>%
  summarise(Probability=mean(sub),ci.low=ci.low(sub),ci.high=ci.high(sub))
agr = as.data.frame(agr)
agr$YMin = agr$Probability - agr$ci.low
agr$YMax = agr$Probability + agr$ci.high
summary(agr)
dodge = position_dodge(.9)
agr$Condition = factor(x=gsub("_","\n",as.character(agr$redCondition)),levels=c("sub\nnecessary","basic\nsufficient","super\nsufficient"))

library(wesanderson)

pl = ggplot(agr, aes(x=bin_ratio_length_subbasic,y=Probability)) +
  geom_bar(stat="identity",position=dodge,color="black") +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25, position=dodge) +
  scale_x_discrete(name="Sub level length",breaks=c("short","long"),labels=c("short\n ","long\n ")) +
  scale_fill_manual(values=wes_palette("Darjeeling2"),name="Length") +
  scale_y_continuous(name="Proportion of sub level mention",breaks=seq(0,1,.2)) +
  facet_wrap(~Condition) +
  theme(axis.title.y = element_blank(),axis.title.x = element_text(size=10),axis.text.y = element_text(size=8),plot.margin=unit(c(0,0,0,0.2), "cm"))
#theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))
#ggsave("/Users/titlis/cogsci/projects/stanford/projects/overinformativeness/writing/2016/cogsci/graphs/length-effect.pdf",height=4.2,width=6)

# main effect of typicality
d$bin_typ_subbasic = cut_number(d$ratio_typ_subbasic,2,labels=c("less typical","more typical"))#,labels=c("short","mid","long"))

summary(cut_number(d$ratio_typ_subbasic,2))

agr = d %>%
  select(sub, bin_typ_subbasic,redCondition) %>%
  group_by(bin_typ_subbasic,redCondition) %>%
  summarise(Probability=mean(sub),ci.low=ci.low(sub),ci.high=ci.high(sub))
agr = as.data.frame(agr)
agr$YMin = agr$Probability - agr$ci.low
agr$YMax = agr$Probability + agr$ci.high
summary(agr)
dodge = position_dodge(.9)
agr$Condition = factor(x=gsub("_","\n",as.character(agr$redCondition)),levels=c("sub\nnecessary","basic\nsufficient","super\nsufficient"))
#agr$Condition = factor(x=as.character(agr$redCondition),levels=c("sub_necessary","basic_sufficient","super_sufficient"))
agr$Typicality = factor(x=as.character(agr$bin_typ_subbasic),levels=c("more typical","less typical"))

pt = ggplot(agr, aes(x=Typicality,y=Probability)) +
  geom_bar(stat="identity",position=dodge,color="black") +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25, position=dodge) +
  scale_x_discrete(name="Sub level typicality",breaks=c("more typical","less typical"),labels=c("more\ntypical","less\ntypical")) +
  #scale_fill_manual(values=wes_palette("Darjeeling2"),name="Length") +
  scale_y_continuous(name="Proportion of sub level mention",breaks=seq(0,1,.2)) +
  facet_wrap(~Condition) +
  theme(axis.title.y = element_blank(),axis.title.x = element_text(size=10),axis.text.y = element_text(size=8),plot.margin=unit(c(0,0,0,0.2), "cm"))

library(gridExtra)
library(grid)
pdf("../writing/pics/lengthtypicality.pdf",height=3.5,width=8)
grid.arrange(pl,pt,nrow=1,  left = textGrob("Proportion of sub level mention", rot = 90, vjust = 1,gp = gpar(cex = .9)))
dev.off()


######### LOOK AT QUALITATIVE CASES
grizzly = droplevels(d[d$target_sub == "grizzlybear",])
grizzly$koala_alt = as.factor(ifelse(grizzly$alt1_sub == "koalabear" | grizzly$alt2_sub == "koalabear",1,0))
table(grizzly$koala_alt,grizzly$basic,grizzly$condition)

panda = droplevels(d[d$target_sub == "pandabear",])
table(panda$condition,panda$sub)

hummingbird = droplevels(d[d$target_sub == "hummingbird",])
table(hummingbird$condition,hummingbird$sub)

pug = droplevels(d[d$target_sub == "pug",])
table(pug$condition,pug$sub)
13/44 # = .295, proportion of sub level mentions in basic and super sufficient conditions

gs = droplevels(d[d$target_sub == "germanshepherd",])
table(gs$condition,gs$sub)
4/35 # = .11, proportion of sub level mentions in basic and super sufficient conditions




##### Modeling plots (this code was originally in writing/rscripts/plots.R)

##FIXME: these paths are not correct (files dont exist in new repo yet)

# Exp 3 - nominal choice: qualitative pattern (blue plot) across all models
a = read.table("../../../../models/5a_bda_nom_det_nocost/predictive-barplot-fulldataset-detfit-nocost-hmc.txt",sep="\t",header=T,quote="")
b = read.table("../../../../models/5b_bda_nom_det/predictive-barplot-fulldataset-detfit-hmc.txt",sep="\t",header=T,quote="")
c = read.table("../../../../models/5c_bda_nom_full_nocost/predictive-barplot-fulldataset-typicalities-nocost-hmc.txt",sep="\t",header=T,quote="")
d = read.table("../../../../models/5d_bda_nom_full/predictive-barplot-fulldataset-typicalities-hmc.txt",sep="\t",header=T,quote="")
emp = read.table("../../../../models/5d_bda_nom_full/predictive-barplot-empirical.txt",sep="\t",header=T,quote="")

dd = rbind(a,b,c,d,emp)
nrow(dd)

dd$Utt = factor(x=dd$Utterance,levels=c("sub","basic","super"))
ggplot(dd, aes(x=condition,y=Probability,fill=ModelType)) +
  geom_bar(stat="identity",color="black") +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25) +
  scale_fill_brewer(guide=F) +
  ylab("Utterance probability") +
  xlab("Condition") +
  facet_grid(ModelType~Utt) +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1),plot.margin=unit(c(0,0,0,0),"cm"))
ggsave("../writing/pics/qualitativepattern-complete.pdf",height=8.5,width=6)

# nominal choice: scatterplot across all models
a = read.table("../../../../models/5a_bda_nom_det_nocost/predictive-scatterplot-fulldataset-detfit-nocost-hmc.txt",sep="\t",header=T,quote="")
b = read.table("../../../../models/5b_bda_nom_det/predictive-scatterplot-fulldataset-detfit-hmc.txt",sep="\t",header=T,quote="")
c = read.table("../../../../models/5c_bda_nom_full_nocost/predictive-scatterplot-fulldataset-typicalities-nocost-hmc.txt",sep="\t",header=T,quote="")
d = read.table("../../../../models/5d_bda_nom_full/predictive-scatterplot-fulldataset-typicalities-hmc.txt",sep="\t",header=T,quote="")

dd = rbind(a,b,c,d)
dd$Condition = dd$condition

ggplot(dd, aes(x=MAP,y=EmpProportion,shape=Condition,color=Utterance)) +
  geom_abline(intercept=0,slope=1,color="gray60") +
  geom_point() +
  xlim(c(0,1)) +
  ylim(c(0,1)) +
  ylab("Empirical proportion") +
  xlab("Model predicted probability") +
  facet_wrap(~ModelType,nrow = 2)
# ggsave("scatterplot-complete.pdf",height=3,width=11.5)
ggsave("../writing/pics/scatterplot-complete.pdf",height=5.5,width=7.5)


