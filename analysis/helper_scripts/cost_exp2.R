library(gbNgram)
library(jsonlite)
library(tidyr)

# search single-word utteranes (for some reason you need to do this in two steps for correct results)
d1 <- ngram(terms=c("apple","avocado","banana","carrot","pear","pepper","tomato","black","blue","brown","green","orange"),yr.start=1960)
d2 <- ngram(terms=c("purple","red","yellow"),yr.start=1960)
d1 = as.data.frame(colSums(d1[,-length(colnames(d1))]))
d2 = as.data.frame(colSums(d2[,-length(colnames(d2))]))
colnames(d1) = c("Frequency")
colnames(d2) = c("Frequency")
d = rbind(d1,d2)
d$Utterance = row.names(d)

# search two-word utterances (for some reason it returns an error when a term isn't found, so you need to include some error handling to just return zero when necessary)
pairs = c("black avocado","black pepper","blue apple","blue banana","brown banana","brown carrot","green apple","green avocado","green pear","green pepper","green tomato","orange carrot","orange pear","orange pepper","purple carrot","purple tomato","red apple","red avocado","red pepper","red tomato","yellow banana","yellow pear")

for (p in pairs) {
 out = tryCatch(
      { colSums(ngram_group(strsplit(p, " ")[[1]][2],strsplit(p, " ")[[1]][1],yr.start=1960)) 
      },
      error=function(cond) {
      message(paste("term not found: ", p))
      message("Here's the original error message:")
      message(cond)
      # Choose a return value in case of error
      return(0)
    },
    warning=function(cond) {
      message(paste("pair cause warning:", p))
      message("Here's the original warning message:")
      message(cond)
      # Choose a return value in case of warning
      return(0)
    },
    finally={
      message(paste("Processed pair:", p))
    }
    )
 d[p,"Frequency"] = out[[1]]
 d[p,"Utterance"] = paste(strsplit(p," ")[[1]][1],strsplit(p," ")[[1]][2],sep="_")
}

d[d$Frequency == 0,]$Frequency = min(d[d$Frequency>0,]$Frequency)/10
d$logFrequency = log(d$Frequency)
freqs = d %>%
  select(Utterance,logFrequency) %>%
  spread(Utterance,logFrequency)

write(toJSON(freqs, pretty=TRUE),file=here("frequencies.json"))

lengths = data.frame(Utterance = c("black_avocado","black_pepper","blue_apple","blue_banana","brown_banana","brown_carrot","green_apple","green_avocado","green_pear","green_pepper","green_tomato","orange_carrot","orange_pear","orange_pepper","purple_carrot","purple_tomato","red_apple","red_avocado","red_pepper","red_tomato","yellow_banana","yellow_pear","apple","avocado","banana","carrot","pear","pepper","tomato","black","blue","brown","green","orange","purple","red","yellow"))
lengths$Length = nchar(as.character(lengths$Utterance))
lengths = lengths %>%
  spread(Utterance,Length)

write(toJSON(lengths, pretty=TRUE),file=here("lengths.json"))

# create cost file
lengths = as.data.frame(t(lengths))
lengths$target = rownames(lengths)
lengths$length = lengths$`1`
lengths = lengths[,c("target","length")]
freqs = as.data.frame(t(freqs))
freqs$target = rownames(freqs)
freqs$freq = freqs$`1`
freqs = freqs[,c("target","freq")]
cost = merge(lengths,freqs)

write.csv(cost, file=here("data","cost_exp2.csv"),row.names=F,quote=F)
