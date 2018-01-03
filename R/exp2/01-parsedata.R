rm(list = ls())

pth <- "../data/exp2/responses/"

files <- list.files(pth, pattern = "*.csv", full.names = T)

df <- do.call("rbind",lapply(files,FUN=function(f) {read.csv(f, skip = 1, stringsAsFactors = F)}))

str(df)
df <- filter(df, subject != 1)
save(df,file = "../data/exp2/responses/responses_150622.RData")
