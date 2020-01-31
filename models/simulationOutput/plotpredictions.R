library(tidyverse)

this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

######### PLOT SPEAKER #########

dspeaker = read.table("colorsize_variation.csv",sep=",")
colnames(dspeaker) = c("alpha","lengthWeight","typicality_color","typicality_size","typicality_type","cost_color","cost_size","condition","utterance","probability")
dspeaker$sufficientdimension = sapply(strsplit(as.character(dspeaker$condition),"_"), "[", 1)
dspeaker$numdistractors = as.numeric(as.character(sapply(strsplit(as.character(dspeaker$condition),"_"), "[", 2)))
dspeaker$numsame = as.numeric(as.character(sapply(strsplit(as.character(dspeaker$condition),"_"), "[", 3)))
dspeaker$numdiff = dspeaker$numdistractors - dspeaker$numsame
dspeaker$scenevariation = dspeaker$numdiff/dspeaker$numdistractors
dspeaker$utterancetype = "other"
dspeaker[dspeaker$utterance == "big_blue_thing",]$utterancetype = "redundant"
dspeaker$ratiodifftosame = dspeaker$numdiff/dspeaker$numsame
dspeaker[dspeaker$utterance == "blue_thing" & dspeaker$sufficientdimension == "color",]$utterancetype = "minimal"
dspeaker[dspeaker$utterance == "big_thing" & dspeaker$sufficientdimension == "size",]$utterancetype = "minimal"
head(dspeaker)
summary(dspeaker)
nrow(dspeaker)

d = dspeaker

# paper plot of scene variation effect with same parameters as in koolen plot
d$numdistractors = as.factor(as.character(d$numdistractors))
d$typicality_color = as.factor(as.character(d$typicality_color))
d$RedundantDimension = as.factor(ifelse(d$sufficientdimension == "color","size redundant","color redundant"))

ggplot(d[d$typicality_color == .999 & d$alpha == 30 & d$typicality_size == .8 & d$utterancetype != "other" & d$utterancetype == "redundant",], aes(x=scenevariation,y=probability,group=RedundantDimension,shape=numdistractors)) +
  geom_smooth(method="lm",size=.5) +
  geom_point(size=.5) +
  scale_shape_discrete(name="Number of distractors") +
  xlab("Scene variation") +
  ylab("Probability of redundant modifier") +
  facet_wrap(~RedundantDimension) +
  theme(panel.border = element_rect(size=.2),
        plot.margin = unit(x = c(0.03, 0.1, 0.03, 0.03), units = "in"),
        panel.grid = element_line(size = .4),
        panel.spacing = unit(2,"pt"),
        axis.line        = element_line(colour = "black", size = .2),
        axis.ticks       = element_line(colour = "black", size = .2),
        axis.ticks.length = unit(2, "pt"),
        axis.text.x        = element_text(size = 6 * scale_value, colour = "black",vjust=2),
        axis.text.y        = element_text(size = 6 * scale_value, colour = "black",margin = margin(r = 0.3)),#,hjust=-5),
        axis.title.x       = element_text(size = 6 * scale_value, margin = margin(t = .5)),
        axis.title.y       = element_text(size = 6 * scale_value, margin = margin(r = .7)),
        strip.text      = element_text(size = 6 * scale_value,margin=margin(t=4,b=4,unit="pt")),
        legend.text      = element_text(margin = margin(l = -2, r=0, unit = "pt"), size = 6 * scale_value),
        legend.title     = element_text(size = 6, face = "bold"),
        legend.position  = "bottom",#c(0.5,-.5),
        legend.direction = "horizontal",
        legend.box = "horizontal",
        legend.spacing.x = unit(.1, 'pt'),
        # legend.box.spacing = unit(2,"pt"),
        legend.margin=margin(0,5,0,0), # change space between sub-legends
        legend.box.margin=margin(-15,0,0,0) # change space between legend and plot
  )
ggsave("../../writing/pics/fig4.tiff",units="in",width=2.7,height=1.7,dpi=600)

