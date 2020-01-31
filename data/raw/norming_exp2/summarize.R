library(here)
library(tidyverse)

this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

col = read.csv(here("data","raw","norming_exp2","typicality_exp2_color.csv"))
type = read.csv(here("data","raw","norming_exp2","typicality_exp2_type.csv"))
col_type = read.csv(here("data","raw","norming_exp2","typicality_exp2_color-and-type.csv"))

col$UtteranceType = "color-only"
type$UtteranceType = "type-only"
col_type$UtteranceType = "color-and-type"

typicality = rbind(col,type,col_type)
typicality = typicality %>%
  unite(FullItem,Color:Item,sep=" ")

typical = c("red apple", "green avocado", "yellow banana", "orange carrot", "green pear", "red pepper","green pepper", "red tomato")

atypical = c("blue apple", "red avocado", "blue banana", "brown carrot", "orange pear", "black pepper", "purple tomato")

typicality = typicality %>%
  mutate(UtteranceTrue = str_detect(FullItem,as.character(Utterance))) %>%
  mutate(CatTypicality = 
           case_when(UtteranceTrue == FALSE ~ "other",
                    FullItem %in% typical ~ "typical",
                     FullItem %in% atypical ~ "atypical",
                     TRUE ~ "midtypical"))

write.csv(typicality, file = here("data","typicality_exp2.csv"),row.names=F,quote=F)

agr = typicality %>%
  group_by(CatTypicality,UtteranceType) %>%
  summarise(Mean = mean(Typicality),CILow = ci.low(Typicality),CIHigh = ci.high(Typicality)) %>%
  ungroup() %>%
  mutate(YMin=Mean-CILow,YMax=Mean+CIHigh) %>%
  mutate(CatTypicality=fct_relevel(CatTypicality,"typical","midtypical","atypical"),
         UtteranceType=fct_relevel(UtteranceType,"type-only","color-only"))
  
ggplot(agr, aes(x=CatTypicality,y=Mean)) +
  geom_bar(stat="identity",color="black",fill="gray80",size=.25) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25,size=.25) +
  xlab("A priori typicality") +
  ylab("Mean typicality rating") +
  facet_wrap(~UtteranceType) +
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
        strip.text      = element_text(size = 6 * scale_value,margin=margin(t=4,b=4,unit="pt"))
  )
ggsave("../../../writing/pics/fig12.tiff",units="in",width=5,height=2,dpi=600)



