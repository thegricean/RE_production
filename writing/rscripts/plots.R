setwd("/Users/titlis/cogsci/projects/stanford/projects/overinformativeness/writing/2016/theory/pics")

# nominal choice: qualitative pattern (blue plot) across all models
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
ggsave("qualitativepattern-complete.pdf",height=8.5,width=6)

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
ggsave("scatterplot-complete.pdf",height=5.5,width=7.5)
