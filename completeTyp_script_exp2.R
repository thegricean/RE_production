library(dplyr)
library(bootstrap)
library(lme4)
library(tidyr)

theme_set(theme_bw(18))
setwd("/Users/elisakreiss/Documents/Stanford/overinformativeness/experiments/elisa_paper_relevant/norming_full/results")

source("rscripts/helpers.r")

#write json file with all typicalities
output = "{\n"
for (u in unique(agr$Utterance)) {
  output1 = paste("    \"",u,"\" : {\n",sep="")
  output2 = paste("        \"",paste(agr[agr$Utterance == u,]$Combo,agr[agr$Utterance == u,]$RoundMTypicality,sep="\" : "),",\n",sep="",collapse="")
  output = paste(output,output1,output2,"    },\n",sep="")
}

col = read.table(file="../../norming_comp_colorPatch/results/data/meantypicalities.csv",sep=",", header=T)
col$Combo = paste(col$Color,col$Item,sep="_")

for (u in unique(col$color_utterance)) {
  output1 = paste("    \"",u,"\" : {\n",sep="")
  output2 = paste("        \"",paste(col[col$color_utterance == u,]$Combo,col[col$color_utterance == u,]$MeanTypicality,sep="\" : "),",\n",sep="",collapse="")
  output = paste(output,output1,output2,"    },\n",sep="")
}


t = read.table(file="../../norming_comp_object/results/data/meantypicalities.csv",sep=",", header=T)
t$Combo = paste(t$Color,t$Item,sep="_")

for (u in unique(t$utterance)) {
  output1 = paste("    \"",u,"\" : {\n",sep="")
  output2 = paste("        \"",paste(t[t$utterance == u,]$Combo,t[t$utterance == u,]$Typicality,sep="\" : "),",\n",sep="",collapse="")
  output = paste(output,output1,output2,"    },\n",sep="")
}

output = paste(output,"}",sep="")
cat(output)
write.table(output,file="../../completeTypicalities_purple.json",quote=FALSE,sep="",row.names=FALSE,col.names=FALSE)
