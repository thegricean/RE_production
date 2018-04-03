library(here)

col = read.csv(here("data","raw","norming_exp2","typicality_exp2_color.csv"))
type = read.csv(here("data","raw","norming_exp2","typicality_exp2_type.csv"))
col_type = read.csv(here("data","raw","norming_exp2","typicality_exp2_color-and-type.csv"))

col$UtteranceType = "color-only"
type$UtteranceType = "type-only"
col_type$UtteranceType = "color-and-type"

typicality = rbind(col,type,col_type)

write.csv(typicality, file = here("data","typicality_exp2.csv"),row.names=F,quote=F)
