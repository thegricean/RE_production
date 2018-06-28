library(tidyverse)
library(here)

source(here("analysis","helper_scripts","helpers.R"))

typicality_data = read.table(file=here("data","typicality_exp2.csv"),sep=",", header=T)

typicality_data$ObjectCombo = paste(typicality_data$Color,"_",typicality_data$Item,sep="")
typicality_data$UtteranceCombo = ifelse(typicality_data$UtteranceType=="color-and-type",str_replace(typicality_data$Utterance," ","_"),as.character(typicality_data$Utterance))

output = "{\n"
for (u in unique(typicality_data$ObjectCombo)) {
  output1 = paste("    \"",u,"\" : {\n",sep="")
  output2 = paste("        \"",paste(typicality_data[typicality_data$UtteranceCombo == u,]$ObjectCombo,typicality_data[typicality_data$UtteranceCombo == u,]$Typicality,sep="\" : "),",\n",sep="",collapse="")
  output = paste(output,output1,output2,"    },\n",sep="")
}

output = paste(output,"}",sep="")
cat(output)
write.table(output,file=here("models","refModule","json","typicality-meanings.json"),quote=FALSE,sep="",row.names=FALSE,col.names=FALSE)
